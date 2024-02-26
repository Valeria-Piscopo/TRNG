#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>

#include "trng_keccak_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver.h"

int main() 
{   
    
    uint8_t volatile conditioning = 0;
    static uint32_t* Dout[3]; 
    static uint8_t buf[16];
    static int xlen = 16;
    
    //get_rnd_key(conditioning, Dout);

    get_rnd_bytes(conditioning, buf, xlen);

    for(int i = 0; i < 16; i++)
        printf("Key: %08X \n", buf[i]);
    //printf("Key: %04X \n", Dout[0]);
    //printf("Key: %04X \n", Dout[1]);
    //printf("Key: %04X \n", Dout[2]);

    /*conditioning = 1;

    get_rnd_key(conditioning, Dout);

    printf("Key: %04X \n", Dout[0]);
    printf("Key: %04X \n", Dout[1]);
    printf("Key: %04X \n", Dout[2]);*/

    return 0;
}
