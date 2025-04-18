/*******************************************************************************
 * Copyright (C) Maxim Integrated Products, Inc., All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL MAXIM INTEGRATED BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of Maxim Integrated
 * Products, Inc. shall not be used except as stated in the Maxim Integrated
 * Products, Inc. Branding Policy.
 *
 * The mere transfer of this software does not imply any licenses
 * of trade secrets, proprietary technology, copyrights, patents,
 * trademarks, maskwork rights, or any other form of intellectual
 * property whatsoever. Maxim Integrated Products, Inc. retains all
 * ownership rights.
 *
 ******************************************************************************/

FLASH_MEM_SIZE = _RISCV_FLASH_SIZE - _PAL_NVM_SIZE;
FLASH_MEM_ORIGIN = _RISCV_FLASH_ORIGIN - _PAL_NVM_SIZE;

SRAM_MEM_ORIGIN = _RISCV_SRAM_ORIGIN + _MAILBOX_SIZE*2;
SRAM_MEM_SIZE =  _RISCV_SRAM_SIZE - _MAILBOX_SIZE*2;

MAILBOX_ORIGIN = _RISCV_SRAM_ORIGIN;

MEMORY {
    FLASH      (rx) : ORIGIN = FLASH_MEM_ORIGIN, LENGTH = FLASH_MEM_SIZE
    PAL_NVM_DB (r)  : ORIGIN = FLASH_MEM_ORIGIN + FLASH_MEM_SIZE, LENGTH = _PAL_NVM_SIZE
    MAILBOX_0  (rw) : ORIGIN = MAILBOX_ORIGIN, LENGTH = _MAILBOX_SIZE
    MAILBOX_1  (rw) : ORIGIN = MAILBOX_ORIGIN + _MAILBOX_SIZE, LENGTH = _MAILBOX_SIZE
    SRAM      (rwx) : ORIGIN = SRAM_MEM_ORIGIN, LENGTH = SRAM_MEM_SIZE
}

SECTIONS {
    
    .text :
    {
        _text = ALIGN(.,13);
        KEEP(*(.isr_vector))
        KEEP(*(.c_iv))
        *(.text*)    /* program code */

        *(.srodata*) /* read-only data: "const" */
        *(.rodata*)  /* read-only data: "const" */

        KEEP(*(.init))
        KEEP(*(.fini))

        /* C++ Exception handling */
        KEEP(*(.eh_frame*))
        _etext = .;
    } > FLASH

    .mailbox_0 (NOLOAD) :
    {
        _mailbox_0 = ALIGN(., 4); 
        *(.mailbox_0*)           /*Shared memory section*/
        . = . + _MAILBOX_SIZE;
        _emailbox_0 = ALIGN(., 4);
    } > MAILBOX_0

    .mailbox_1 (NOLOAD) :
    {
        _mailbox_1 = ALIGN(., 4);
        *(.mailbox_1*)           /*Shared memory section*/
        . = . + _MAILBOX_SIZE;
        _emailbox_1 = ALIGN(., 4);
    } > MAILBOX_1

    /* short/global data section */
    .sdata :
    {
        _sdata = ALIGN(., 4);
        __sdata_start = .; 
        PROVIDE(__global_pointer$ = . + 0x800);        
        *(.sdata*)  /*read-write initialized data: initialized global variable*/

        _esdata = ALIGN(., 4);
        __sdata_end = .;
    
    } > SRAM AT>FLASH
    __load_sdata = LOADADDR(.sdata);

    .data :
    {
        _data = ALIGN(., 4);
        __data_start__ = . ;            /* Standard newlib definition. */
    
        *(.data*)           /*read-write initialized data: initialized global variable*/
        *(.spix_config*)    /* SPIX configuration functions need to be run from SRAM3 */

        /* These array sections are used by __libc_init_array to call static C++ constructors */
        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        _edata = ALIGN(., 4);
       __data_end__ = . ;                /* Standard newlib definition. */
    } > SRAM AT>FLASH
    __load_data = LOADADDR(.data);

    .sbss :
    {
        . = ALIGN(4);
        __sbss_start = .;                 /* Standard newlib definition. */
    __sbss_start__ = .;                 /* Standard newlib definition. */
        _sbss = .;
        *(.sbss*)     /*read-write zero initialized data: uninitialzed global variable*/
        *(COMMON)
        _esbss = ALIGN(., 4);
        __sbss_end__ = .;                /* Standard newlib definition. */
        __sbss_end = .;                    /* Standard newlib definition. */
    } > SRAM

    .bss :
    {
        . = ALIGN(4);
        __bss_start = .;                 /* Standard newlib definition. */
        __bss_start__ = .;                 /* Standard newlib definition. */
        _bss = .;
        *(.bss*)     /*read-write zero initialized data: uninitialzed global variable*/
        *(COMMON)
        _ebss = ALIGN(., 4);
        __bss_end__ = .;                /* Standard newlib definition. */
    __bss_end = .;                    /* Standard newlib definition. */
     } > SRAM

    .pal_nvm_db :
    {
    /* Align to the sector size */
    . = ALIGN(0x2000);
    __pal_nvm_db_start__ = .;
    . = . + _PAL_NVM_SIZE;
    __pal_nvm_db_end__ = .;
    } > PAL_NVM_DB
     

    /* Set stack top to end of RAM, and stack limit move down by
     * size of stack_dummy section */
    __StackTop = ORIGIN(SRAM) + LENGTH(SRAM);
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);

    /* .stack_dummy section doesn't contains any symbols. It is only
     * used for linker to calculate size of stack sections, and assign
     * values to stack symbols later */
    .stack_dummy (COPY):
    {
        *(.stack*)
    } > SRAM

    .heap (COPY):
    {
        . = ALIGN(4);
        *(.heap*)
        __HeapLimit = ABSOLUTE(__StackLimit);
    } > SRAM

    /* init two words preceding const seg to address and length of segment */
    PROVIDE(__stack = __StackTop);

    /* Check if data + heap + stack exceeds RAM limit */
    ASSERT(__StackLimit >= _ebss, "region RAM overflowed with stack")
}
