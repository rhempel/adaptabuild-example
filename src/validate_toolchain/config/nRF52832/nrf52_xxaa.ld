/* Linker script to configure memory regions. */

SEARCH_DIR(.)
/* GROUP(-lgcc -lc) */

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x80000
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x10000
  CODE_RAM (rwx) : ORIGIN = 0x800000, LENGTH = 0x10000
}

/* -------------------------------------------------------------------------
 * Add custom definitions BELOW this line - everything above should
 * be included from a common file
 */

/* FLASH Page/Sector definitions - for the STM32F0xx devices they have above
 * common sector size of 1K 
*/

OTA_IMAGE_SIZE  = 0x4000;
OTA_IMAGE_START = ORIGIN(FLASH) + LENGTH(FLASH) - OTA_IMAGE_SIZE;
OTA_IMAGE_END   = ORIGIN(FLASH) + LENGTH(FLASH) - 1;

INCLUDE "mdk/nrf_common.ld"
