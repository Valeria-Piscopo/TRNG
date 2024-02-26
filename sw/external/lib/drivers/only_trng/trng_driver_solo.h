#ifndef _TRNG_H_
#define _TRNG_H_

#include <stdint.h>
//#include "core_v_mini_mcu.h"

void trigger_trng(uint8_t conditioning);
//void trigger_trng();
void poll_trng(void);           
void get_key(uint32_t *Dout);
void ack_key(void);

void get_rnd_key(uint8_t conditioning, uint32_t* Dout);
void get_rnd_key_intr(uint8_t conditioning, uint32_t* Dout);
void get_rnd_bytes(uint8_t conditioning, uint8_t* buf, int xlen);

#endif