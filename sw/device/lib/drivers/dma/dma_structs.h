/*
                              *******************
******************************* H SOURCE FILE *******************************
**                            *******************                          **
**                                                                         **
** project  : x-heep                                                       **
** filename : dma_structs.h                                 **
** date     : 22/12/2023                                                      **
**                                                                         **
*****************************************************************************
**                                                                         **
**                                                                         **
*****************************************************************************

*/

/**
* @file   dma_structs.h
* @date   22/12/2023
* @brief  Contains structs for every register
*
* This file contains the structs of the registes of the peripheral.
* Each structure has the various bit fields that can be accessed
* independently.
* 
*/

#ifndef _DMA_STRUCTS_H
#define DMA_STRUCTS

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

#define dma_peri ((volatile dma *) DMA_START_ADDRESS)

/****************************************************************************/
/**                                                                        **/
/**                       TYPEDEFS AND STRUCTURES                          **/
/**                                                                        **/
/****************************************************************************/



typedef struct {

  uint32_t SRC_PTR;                               /*!< Input data pointer (word aligned)*/

  uint32_t DST_PTR;                               /*!< Output data pointer (word aligned)*/

  uint32_t ADDR_PTR;                              /*!< Addess data pointer (word aligned)*/

  uint32_t SIZE;                                  /*!< Number of bytes to copy - Once a value is written, the copy starts*/

  uint32_t STATUS;                                /*!< Status bits are set to one if a given event occurred*/

  uint32_t PTR_INC;                               /*!< Increment number of src/dst pointer every time a word is copied*/

  uint32_t SLOT;                                  /*!< The DMA will wait for the signal     connected to the selected trigger_slots to be high    on the read and write side respectivly*/

  uint32_t DATA_TYPE;                             /*!< Width/type of the data to transfer*/

  uint32_t MODE;                                  /*!< Set the operational mode of the DMA*/

  uint32_t WINDOW_SIZE;                           /*!< Will trigger a every "WINDOW_SIZE" writes    Set to 0 to disable.*/

  uint32_t WINDOW_COUNT;                          /*!< Number of times the end of the window was reached since the beginning.    Reset at start*/

  uint32_t INTERRUPT_EN;                          /*!< Interrupt Enable Register     (Only the interrupt with the lowest id will be triggered)*/

} dma;

/****************************************************************************/
/**                                                                        **/
/**                          EXPORTED VARIABLES                            **/
/**                                                                        **/
/****************************************************************************/

#ifndef _DMA_STRUCTS_C_SRC



#endif  /* _DMA_STRUCTS_C_SRC */

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



#endif /* _DMA_STRUCTS_H */
/****************************************************************************/
/**                                                                        **/
/**                                EOF                                     **/
/**                                                                        **/
/****************************************************************************/
