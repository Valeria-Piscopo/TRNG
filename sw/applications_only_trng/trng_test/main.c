#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>

#include "trng_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver_solo.h"
#include "csr.h"
#include "stats.h"

int main() 
{   
    
    uint8_t volatile conditioning = 0;
    static uint32_t* Dout; 
    static uint8_t* buf[16];
    static int xlen = 16;
    unsigned int instr, cycles, ldstall, jrstall, imstall;

    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);
    
    get_rnd_key(conditioning, Dout);
    //printf("Key: %08X \n", Dout);

    get_rnd_key(conditioning, Dout);
    //printf("Key: %08X \n", Dout);

    //get_rnd_bytes(conditioning, buf, xlen);
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("Number of cycles: %d \n", cycles);

    //for(int i = 0; i < 16; i++)
    //    printf("Key: %08X \n", buf[i]);

    return 0;
}
