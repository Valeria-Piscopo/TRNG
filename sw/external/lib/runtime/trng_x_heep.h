// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef TRNG_X_HEEP_H_
#define TRNG_X_HEEP_H_

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

#include "core_v_mini_mcu.h"

#define TRNG_PERIPH_START_ADDRESS (EXT_PERIPHERAL_START_ADDRESS + 0x0000000)
#define TRNG_PERIPH_SIZE 0x0001000
#define TRNG_PERIPH_END_ADDRESS (TRNG_PERIPH_START_ADDRESS + TRNG_PERIPH_SIZE)

#define TRNG_IO_START_ADDRESS (EXT_SLAVE_START_ADDRESS + 0x0000000)
#define TRNG_IO_SIZE 0x0001000
#define TRNG_IO_END_ADDRESS (TRNG_IO_START_ADDRESS + TRNG_IO_SIZE)


#define TRNG_DIN_START_ADDR TRNG_IO_START_ADDRESS
#define TRNG_DOUT_START_ADDR (TRNG_IO_START_ADDRESS+0x0000000c8)

#define TRNG_CTRL_START_ADDR TRNG_PERIPH_START_ADDRESS
#define TRNG_STATUS_START_ADDR (TRNG_PERIPH_START_ADDRESS+0x00000004)

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // TRNG_X_HEEP_H_