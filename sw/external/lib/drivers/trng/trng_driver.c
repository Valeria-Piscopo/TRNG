#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "trng_keccak_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver.h"
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


void trigger_trng(uint8_t conditioning)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;

    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = conditioning << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
    int volatile i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;   
}


void poll_trng()
{
    uint32_t volatile *status_reg = (uint32_t*) KECCAK_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    do {
        key_ready = (*status_reg) & (1 << TRNG_KECCAK_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);
}

void get_key(uint32_t *Dout)
{
    uint32_t volatile *Dout_reg = (uint32_t*)KECCAK_DOUT_START_ADDR;
    Dout = Dout_reg[50];
}

void ack_key()
{
    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;

    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
}

void get_rnd_key(uint8_t conditioning, uint32_t* Dout[3])
{
    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) KECCAK_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) KECCAK_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int instr, cycles, ldstall, jrstall, imstall;
    plic_result_t plic_res; 
    plic_res = plic_Init();     
    plic_res = plic_irq_set_priority(EXT_INTR_1, 1);
    plic_res = plic_irq_set_enabled(EXT_INTR_1, kPlicToggleEnabled);

    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);
    //const uint32_t mask = 1 << 10;//IRQ_EXT_ENABLE_OFFSET;
    //CSR_SET_BITS(CSR_REG_MIE, mask);
    //CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    //*ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
    // Valuta overhead attivazione Keccak HW/SW
    *ctrl_reg = conditioning << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
    // SERVE MASKING DI TUTTI I BIT
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
    int i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;

    // poll
    do {
        key_ready = (*status_reg) & (1 << TRNG_KECCAK_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);

    // get key
    Dout[0] = Dout_reg[50];

    //i = 0;
    //while(i < 100) 
    //    i++;
    //Dout[1] = Dout_reg[50];
    //i = 0;
    //while(i < 100) 
    //    i++;
    //Dout[2] = Dout_reg[50];


    // acknowledge key
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    
    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate key: %d\n", cycles);
}

//void get_rnd_bytes(uint8_t conditioning, uint32_t* buf, int xlen)
//{
//    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;
//    uint32_t volatile *Dout_reg = (uint32_t*) KECCAK_DOUT_START_ADDR;
//    uint32_t volatile *status_reg = (uint32_t*) KECCAK_STATUS_START_ADDR;
//    uint8_t volatile key_ready;
//    // Performance regs variables
//	unsigned int instr, cycles, ldstall, jrstall, imstall;
//    plic_result_t plic_res; 
//    plic_res = plic_Init();     
//    plic_res = plic_irq_set_priority(EXT_INTR_1, 1);
//    plic_res = plic_irq_set_enabled(EXT_INTR_1, kPlicToggleEnabled);
//
//    // Starting the performance counter
//    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
//    CSR_WRITE(CSR_REG_MCYCLE, 0);
//
//    //// trigger 
//    //asm volatile ("": : : "memory");
//    //*ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
//    //asm volatile ("": : : "memory");
////
//    //// Valuta overhead attivazione Keccak HW/SW
//    //*ctrl_reg = conditioning << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
//    //// SERVE MASKING DI TUTTI I BIT
//    //asm volatile ("": : : "memory");
//    //*ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
//    //int i = 0; 
//    //while(i < 200) // 100 = 3 clk cycles
//    //    i++; 
//    //asm volatile ("": : : "memory");
//    //*ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
////
//    //// poll
//    //do {
//    //    key_ready = (*status_reg) & (1 << TRNG_KECCAK_CTRL_STATUS_TRNG_BIT);
//    //} while (key_ready == 0);
////
//    //// get keys
//    //while(xlen > 0) {
//    //    buf[xlen] = Dout_reg[50];
//    //    i = 0;
//    //    while(i < 100)
//    //        i++;
//    //    xlen = xlen - 4;
//    //}
//
//    // acknowledge key
//    //*ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
//    
//
//    //2441 cycles
//    trigger_trng(conditioning);
//    for (int i = 0; i < xlen; i++){
//        poll_trng();
//        get_key(buf[i]);
//        ack_key();
//    }
//
//    // stop the HW counter used for monitoring
//    CSR_READ(CSR_REG_MCYCLE, &cycles);
//    printf("\nNumber of clock cycles to generate key: %d\n", cycles);
//}

void get_rnd_bytes(uint8_t conditioning, uint8_t *buf, int xlen)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) KECCAK_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) KECCAK_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int instr, cycles, ldstall, jrstall, imstall;
    plic_result_t plic_res; 
    plic_res = plic_Init();     
    plic_res = plic_irq_set_priority(EXT_INTR_1, 1);
    plic_res = plic_irq_set_enabled(EXT_INTR_1, kPlicToggleEnabled);

    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");

    *ctrl_reg = conditioning << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
    // SERVE MASKING DI TUTTI I BIT
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
    int i = 0; 
    while(i < 200) // 100 = 3 clk cycles
        i++; 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;

    // to divide 32 bits in 8 bit at a time
    for (int i = 0; i < xlen; i++){
        // poll
        do {
            key_ready = (*status_reg) & (1 << TRNG_KECCAK_CTRL_STATUS_TRNG_BIT);
        } while (key_ready == 0);
        
        // get keys
        buf[i] = (uint8_t) Dout_reg[50];

    }

    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate key: %d\n", cycles);
}
