#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "trng_keccak_x_heep.h"
#include "core_v_mini_mcu.h"
#include "keccak_driver.h"
#include "trng_keccak_ctrl_auto.h"
#include "trng_keccak_data_auto.h"

#include "stats.h"

// To manage interrupt
#include "csr.h"
#include "rv_plic.h"
#include "rv_plic_regs.h"
#include "rv_plic_structs.h"
#include "hart.h"

// To manage DMA
#include "dma.h"

#define KECCAK_BUSY 0
#define DATA_SIZE 50

#ifndef USE_DMA
#define USE_DMA 1
#endif

// Interrupt controller variables
plic_result_t plic_res;

// Own defined ext interrupt handler
void handler_irq_ext(uint32_t id){
  //printf("D\n");
}

  
void KeccakF1600_StatePermute(uint32_t* Din, uint32_t* Dout)
{
#pragma message ("USE_DMA set to: " USE_DMA);
  uint32_t volatile *Din_reg_start = (uint32_t*)KECCAK_DIN_START_ADDR;
  uint32_t volatile *ctrl_reg = (uint32_t*)KECCAK_CTRL_START_ADDR;
  uint32_t volatile *status_reg = (uint32_t*)KECCAK_STATUS_START_ADDR;
  uint32_t current_status;
  uint32_t volatile *Dout_reg_start = (uint32_t*)KECCAK_DOUT_START_ADDR;
  
  // Performance regs variables
  unsigned int instr, cycles, ldstall, jrstall, imstall;
  
  uint32_t* ext_addr_4B_PTR = (uint32_t*)KECCAK_DIN_START_ADDR;
 
  // Keccak accelerator send interrupt on ext_intr line 0
  //printf("Interrupt id : %d\n", EXT_INTR_0);
  //printf("Init the PLIC...");
  plic_res = plic_Init();

  if (plic_res != kPlicOk) {
      return -1;
  }
  //printf("Number of clock cycles : %d\n", cycles);
  
  // Set Keccak priority to 1 (target threshold is by default 0) to trigger an interrupt to the target (the processor)
    plic_res = plic_irq_set_priority(EXT_INTR_0, 1);
    if (plic_res == kPlicOk) {
      //printf("Success\n");
    } else {
      //printf("Fail\n;");
    }

  // Enable the interrupt in reg 0 
  //printf("Enable Keccak interrupt...");
  plic_res = plic_irq_set_enabled(EXT_INTR_0, kPlicToggleEnabled);
  if (plic_res == kPlicOk) {
    //printf("Success\n");
  } else {
    //printf("Fail\n;");
  }

  // Enable interrupt on processor side
  // Enable global interrupt for machine-level interrupts
  CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
  // Set mie.MEIE bit to one to enable machine-level external interrupts
  const uint32_t mask = 1 << 11;//IRQ_EXT_ENABLE_OFFSET;
  CSR_SET_BITS(CSR_REG_MIE, mask);

  // Starting the performance counter
  CSR_WRITE(CSR_REG_MCYCLE, 0);

  #if USE_DMA == 1
  //printf("Keccak : using DMA\n");
  // The DMA is initialized (i.e. Any current transaction is cleaned.)
  dma_init(NULL);
    
  dma_config_flags_t res;

  //printf("din_src_ptr: %04x, keccak_din_ptr : %04x\n", Din_4B, ext_addr_4B_PTR);

  // First DMA transaction consist on loading Din in Keccak register file
   
  dma_target_t tgt_src = {
                              .ptr        = Din,
                              .inc_du     = 1,
                              .size_du    = DATA_SIZE,
                              .trig       = DMA_TRIG_MEMORY,
                              .type       = DMA_DATA_TYPE_WORD,
                              };
  dma_target_t tgt_dst = {
                              .ptr        = ext_addr_4B_PTR,
                              .inc_du     = 1,
                              .size_du    = DATA_SIZE,
                              .trig       = DMA_TRIG_MEMORY,
                              };

  dma_target_t tgt_addr = {
                              .ptr        = ext_addr_4B_PTR,
                              .inc_du     = 1,
                              .size_du    = DATA_SIZE,
                              .trig       = DMA_TRIG_MEMORY,
                              };

  dma_trans_t trans = {
                              .src        = &tgt_src,
                              .dst        = &tgt_dst,
                              .src_addr   = &tgt_addr,
                              .mode       = DMA_TRANS_MODE_SINGLE,
                              .win_du     = 0,
                              .end        = DMA_TRANS_END_INTR,
                              };
  // Create a target pointing at the buffer to be copied. Whole WORDs, no skippings, in memory, no environment.  

 //printf("\n\n=====================================\n\n");
 //printf("    TESTING SINGLE MODE WITH KECCAK  ");
 //printf("\n\n=====================================\n\n");
 //
  res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
  //printf("tran: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
  res = dma_load_transaction(&trans);
  //printf("load: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
  res = dma_launch(&trans);
  //printf("laun: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");

  while( ! dma_is_ready()) {
      // disable_interrupts
      // this does not prevent waking up the core as this is controlled by the MIP register
      CSR_SET_BITS(CSR_REG_MSTATUS, 0x0);
      if ( dma_is_ready() == 0 ) {
          wait_for_interrupt();
          //from here we wake up even if we did not jump to the ISR
      }
      CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
  }


  //printf(">> Finished transaction Din. \n");

  #else
  //printf("Keccak : not using DMA\n");
  for (int i = 0; i<50; i++)
  {
     Din_reg_start[i] = Din[i];
  }

  #endif
  
  asm volatile ("": : : "memory");
  *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_KECCAK_EN_BIT;
  asm volatile ("": : : "memory");
  *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_KECCAK_EN_BIT;

  // Wait till keccak is done
  while(plic_intr_flag==0) {
      wait_for_interrupt();
  }
  //printf("Keccak finished...\n");
	 
  #if USE_DMA == 1

  ext_addr_4B_PTR = (uint32_t*)KECCAK_DOUT_START_ADDR;
  tgt_src.ptr = ext_addr_4B_PTR;
  tgt_dst.ptr = Dout;

  //printf("dout_dst_ptr: %04x, keccak_dout_ptr : %04x\n", Dout_4B, ext_addr_4B_PTR);

  // Second DMA transaction consist on reading Dout from Keccak register file

  res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
  //printf("tran: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
  res = dma_load_transaction(&trans);
  //printf("load: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
  res = dma_launch(&trans);
  //printf("laun: %u \t%s\n", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");

  while( ! dma_is_ready()) {
      // disable_interrupts
      // this does not prevent waking up the core as this is controlled by the MIP register
      CSR_SET_BITS(CSR_REG_MSTATUS, 0x0);
      if ( dma_is_ready() == 0 ) {
          wait_for_interrupt();
          //from here we wake up even if we did not jump to the ISR
      }
      CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
  }

  //printf(">> Finished transaction Dout. \n");
     
  #else
  for (volatile int i = 0; i<DATA_SIZE; i++){
     Dout[i] = Dout_reg_start[i];
     //printf("Dout[%d]=%04X\n", i, Dout[i]);
  }

  #endif

  // stop the HW counter used for monitoring
  CSR_READ(CSR_REG_MCYCLE, &cycles);
  printf("Number of clock cycles : %d\n", cycles);
  //printf("Number of instructions : %d\nNumber of clock cycles: %d\nCPI: %f%f\n",instr_cnt, cycles_cnt, (float) instr_cnt/cycles_cnt);
  
}
