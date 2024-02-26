// Generated register defines for trng_keccak_ctrl

#ifndef _TRNG_KECCAK_CTRL_REG_DEFS_
#define _TRNG_KECCAK_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define TRNG_KECCAK_CTRL_PARAM_REG_WIDTH 32

// Choose mode of operation of Keccak+TRNG block
#define TRNG_KECCAK_CTRL_CTRL_REG_OFFSET 0x0
#define TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT 0
#define TRNG_KECCAK_CTRL_CTRL_KECCAK_EN_BIT 1
#define TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT 2
#define TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT 3

//  Contains status information about Keccak/TRNG
#define TRNG_KECCAK_CTRL_STATUS_REG_OFFSET 0x4
#define TRNG_KECCAK_CTRL_STATUS_KECCAK_BIT 0
#define TRNG_KECCAK_CTRL_STATUS_TRNG_BIT 1

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _TRNG_KECCAK_CTRL_REG_DEFS_
// End generated register defines for trng_keccak_ctrl