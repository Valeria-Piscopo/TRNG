/*
                              *******************
******************************* H SOURCE FILE *******************************
**                            *******************                          **
**                                                                         **
** project  : x-heep                                                       **
** filename : rv_timer_structs.h                                 **
** date     : 22/12/2023                                                      **
**                                                                         **
*****************************************************************************
**                                                                         **
**                                                                         **
*****************************************************************************

*/

/**
* @file   rv_timer_structs.h
* @date   22/12/2023
* @brief  Contains structs for every register
*
* This file contains the structs of the registes of the peripheral.
* Each structure has the various bit fields that can be accessed
* independently.
* 
*/

#ifndef _RV_TIMER_STRUCTS_H
#define RV_TIMER_STRUCTS

/****************************************************************************/
/**                                                                        **/
/**                            MODULES USED                                **/
/**                                                                        **/
/****************************************************************************/

#include <inttypes.h>
#include "core_v_mini_mcu.h"

/****************************************************************************/
/**                                                                        **/
/**                       DEFINITIONS AND MACROS                           **/
/**                                                                        **/
/****************************************************************************/

#define rv_timer_peri ((volatile rv_timer *) RV_TIMER_START_ADDRESS)

/****************************************************************************/
/**                                                                        **/
/**                       TYPEDEFS AND STRUCTURES                          **/
/**                                                                        **/
/****************************************************************************/



typedef struct {

  uint32_t _reserved_0[64];                       /*!< reserved addresses*/

  uint32_t CFG0;                                  /*!< Configuration for Hart 0*/

  uint32_t TIMER_V_LOWER0;                        /*!< Timer value Lower*/

  uint32_t TIMER_V_UPPER0;                        /*!< Timer value Upper*/

  uint32_t COMPARE_LOWER0_0;                      /*!< Timer value Lower*/

  uint32_t COMPARE_UPPER0_0;                      /*!< Timer value Upper*/

  uint32_t _reserved_1[59];                       /*!< reserved addresses*/

  uint32_t CFG1;                                  /*!< Configuration for Hart 1*/

  uint32_t TIMER_V_LOWER1;                        /*!< Timer value Lower*/

  uint32_t TIMER_V_UPPER1;                        /*!< Timer value Upper*/

  uint32_t COMPARE_LOWER1_0;                      /*!< Timer value Lower*/

  uint32_t COMPARE_UPPER1_0;                      /*!< Timer value Upper*/

} rv_timer;

/****************************************************************************/
/**                                                                        **/
/**                          EXPORTED VARIABLES                            **/
/**                                                                        **/
/****************************************************************************/

#ifndef _RV_TIMER_STRUCTS_C_SRC



#endif  /* _RV_TIMER_STRUCTS_C_SRC */

/****************************************************************************/
/**                                                                        **/
/**                          EXPORTED FUNCTIONS                            **/
/**                                                                        **/
/****************************************************************************/


/****************************************************************************/
/**                                                                        **/
/**                          INLINE FUNCTIONS                              **/
/**                                                                        **/
/****************************************************************************/



#endif /* _RV_TIMER_STRUCTS_H */
/****************************************************************************/
/**                                                                        **/
/**                                EOF                                     **/
/**                                                                        **/
/****************************************************************************/
