#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "trng_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver_solo.h"
#include "trng_ctrl_auto.h"
#include "trng_data_auto.h"

#include "stats.h"

// To manage interrupt
#include "csr.h"
#include "rv_plic.h"
#include "rv_plic_regs.h"
#include "rv_plic_structs.h"
#include "hart.h"

// To manage DMA
#include "dma.h"


void trigger_trng(uint8_t conditioning)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;

    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = conditioning << TRNG_CTRL_CTRL_CONDITIONING_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    int volatile i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;   
}


void poll_trng()
{
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    do {
        key_ready = (*status_reg) & (1 << TRNG_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);
}

void get_key(uint32_t *Dout)
{
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    Dout = Dout_reg[50];
}

void ack_key()
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;

    *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
}

void get_rnd_key(uint8_t conditioning, uint32_t* Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int instr, cycles, ldstall, jrstall, imstall;

    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    // Valuta overhead attivazione Keccak HW/SW
    *ctrl_reg = conditioning << TRNG_CTRL_CTRL_CONDITIONING_BIT;
    // SERVE MASKING DI TUTTI I BIT
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    int i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;

    // poll
    do {
        key_ready = (*status_reg) & (1 << TRNG_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);
  
    // get key
    //Dout = Dout_reg[50];
    //printf("Key: %08X \n", Dout);
    // acknowledge key
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    
    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    //printf("\nNumber of clock cycles to generate key: %d\n", cycles);
}

void get_rnd_key_intr(uint8_t conditioning, uint32_t* Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int instr, cycles, ldstall, jrstall, imstall;

    // Interrupt 
    plic_result_t plic_res; 
    plic_res = plic_Init();     
    plic_res = plic_irq_set_priority(EXT_INTR_0, 1);
    plic_res = plic_irq_set_enabled(EXT_INTR_0, kPlicToggleEnabled);

    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    // Valuta overhead attivazione Keccak HW/SW
    *ctrl_reg = conditioning << TRNG_CTRL_CTRL_CONDITIONING_BIT;
    // SERVE MASKING DI TUTTI I BIT
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    int i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    
    while(plic_intr_flag==0) {
        wait_for_interrupt();
    }
  
    // get key
    Dout = Dout_reg[50];

    // acknowledge key
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate key: %d\n", cycles);
}


void get_rnd_bytes(uint8_t conditioning, uint8_t *buf, int xlen)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int instr, cycles, ldstall, jrstall, imstall;
    plic_result_t plic_res; 
    plic_res = plic_Init();     
    plic_res = plic_irq_set_priority(EXT_INTR_1, 1);
    plic_res = plic_irq_set_enabled(EXT_INTR_1, kPlicToggleEnabled);

    // Starting the performance counter
    //CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    //CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");

    *ctrl_reg = conditioning << TRNG_CTRL_CTRL_CONDITIONING_BIT;
    // SERVE MASKING DI TUTTI I BIT
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    int i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;

    // to divide 32 bits in 8 bit at a time
    for (int i = 0; i < xlen; i++) {
        // poll
        do {
            key_ready = (*status_reg) & (1 << TRNG_CTRL_STATUS_TRNG_BIT);
        } while (key_ready == 0);
        
        //i = 0; 
        // get keys
         
        buf[i] = (uint8_t) Dout_reg[50];
        printf("%X\n", Dout_reg[50]);
        printf("%X\n", buf[i]);
    }
    // asm volatile ("": : : "memory");
    //*ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;

    // stop the HW counter used for monitoring
    //CSR_READ(CSR_REG_MCYCLE, &cycles);
    //printf("\nNumber of clock cycles to generate key: %d\n", cycles);
}
