/*
 *****************************************************************************
 * linker_script.ld
 *
 * Linker script template for STM32 single core devices
 *
 * Investigate setting up project or device level definitions and then
 * including a common linker script that sets up everything needed for the c
 * runtime environment
 *
 * The common linker template can be used to build images that may have
 * the FLASH space divided up into multiple sections that support:
 *
 * BOOTSTRAP   (optional)
 * BOOTLOADER  (optional)
 * APPLICATION (required)
 * FILESYSTEM  (optional)
 * OTA         (optional)
 * CONFIG      (optional)
 *
 * Similary the RAM space can be set up with sections that support some
 * additional use cases such as:
 *
 * TRANSFER (optional space for transferring between bootloader and app)
 *
 * NOTE WELL: This file structure is being actively developed and is
 *            not yet complete. Try to keep the customization above and below
 *            the markers so that the common part of the file can be included
 *            as needed, and minimizes the projects and target specific
 *            linker script contents
 *****************************************************************************
 */

DEVICE_RAM_SIZE   = 8K;
DEVICE_FLASH_SIZE = 64K;

/* Add custom definitions ABOVE this line - everything below should
 * be included from a common file
 * -------------------------------------------------------------------------*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = 0x20002000;    /* end of RAM */
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x200;      /* required amount of heap  */
_Min_Stack_Size = 0x400; /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = DEVICE_RAM_SIZE
FLASH (rx) : ORIGIN = 0x08000000, LENGTH = DEVICE_FLASH_SIZE
}

INCLUDE gen.blinky.inst.ld

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

        INCLUDE gen.blinky.text.ld

        /* Compile-time process description block */
        . = ALIGN(0x4);
        __applications_start = .;
        KEEP(*(.applications))
        __applications_end = .;

        /* Compile-time thread auto-create block */
        __thread_create_start = .;
        KEEP(*(.thread_create))
        __thread_create_end = .;

        /* Compile-time collected syscall descriptions */
        __syscall_start = .;
        KEEP(*(.syscall))
        __syscall_end = .;

        /* RPC interface VTABLEs */
        INCLUDE gen.blinky.vtable.ld

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >FLASH

  /* Publish FLASH base address as a symbol accessible from C */
  __cmrx_flash_origin = ORIGIN(FLASH);
  /* Publish FLASH size as a symbol accessible from C */
  __cmrx_flash_length = LENGTH(FLASH);

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */

    INCLUDE gen.blinky.data.ld

    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> FLASH

  
  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss section */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;

    INCLUDE gen.blinky.bss.ld

    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  .shared : {
        INCLUDE gen.blinky.shared.ld
  } > RAM

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  /* Remove information from the standard libraries */
  /*
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
  */

  .ARM.attributes 0 : { *(.ARM.attributes) }
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