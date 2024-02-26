// Generated register defines for trng_ctrl

#ifndef _TRNG_CTRL_REG_DEFS_
#define _TRNG_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define TRNG_CTRL_PARAM_REG_WIDTH 32

// Choose mode of operation of TRNG block
#define TRNG_CTRL_CTRL_REG_OFFSET 0x0
#define TRNG_CTRL_CTRL_TRNG_EN_BIT 0
#define TRNG_CTRL_CTRL_CONDITIONING_BIT 1
#define TRNG_CTRL_CTRL_ACK_KEY_READ_BIT 2

//  Contains status information about TRNG
#define TRNG_CTRL_STATUS_REG_OFFSET 0x4
#define TRNG_CTRL_STATUS_TRNG_BIT 0

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _TRNG_CTRL_REG_DEFS_
// End generated register defines for trng_ctrl