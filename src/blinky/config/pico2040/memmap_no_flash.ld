OTA_IMAGE_SIZE  = 0x4000;
OTA_IMAGE_START = ORIGIN(RAM) + LENGTH(RAM) - OTA_IMAGE_SIZE;
OTA_IMAGE_END   = ORIGIN(RAM) + LENGTH(RAM) - 1;

/* Based on GCC ARM embedded samples.
   Defines the following symbols for use by code:
    __exidx_start
    __exidx_end
    __etext
    __data_start__
    __preinit_array_start
    __preinit_array_end
    __init_array_start
    __init_array_end
    __fini_array_start
    __fini_array_end
    __data_end__
    __bss_start__
    __bss_end__
    __end__
    end
    __HeapLimit
    __StackLimit
    __StackTop
    __stack (== StackTop)
*/

MEMORY
{
    RAM(rwx) : ORIGIN =  0x20000000, LENGTH = 256k
    SCRATCH_X(rwx) : ORIGIN = 0x20040000, LENGTH = 4k
    SCRATCH_Y(rwx) : ORIGIN = 0x20041000, LENGTH = 4k
}

ENTRY(_entry_point)
INCLUDE gen.blinky.inst.ld

SECTIONS
{
    /* Note in NO_FLASH builds the entry point for both the bootrom, and debugger
       entry (ELF entry point), are *first* in the image, and the vector table
       follows immediately afterward. This is because the bootrom enters RAM
       binaries directly at their lowest address (preferring main RAM over XIP
       cache-as-SRAM if both are used).
    */

    .text : {
        __logical_binary_start = .;
        __reset_start = .;
        KEEP (*(.reset))
        __reset_end = .;
        KEEP (*(.binary_info_header))
        __binary_info_header_end = .;
        . = ALIGN(256);
          KEEP (*(.vectors))
        *(.time_critical*)
        *(.text*)
        . = ALIGN(4);
        *(.init)
        *(.fini)
        /* Pull all c'tors into .text */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)
        /* Followed by destructors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

        *(.eh_frame*)

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

    } > RAM

    /* Publish FLASH base address as a symbol accessible from C */
/*    __cmrx_flash_origin = ORIGIN(FLASH);
*/
    __cmrx_flash_origin = ORIGIN(RAM);

    .rodata : {
        *(.rodata*)
        . = ALIGN(4);
        *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.flashdata*)))
        . = ALIGN(4);
    } > RAM

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > RAM

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > RAM
    __exidx_end = .;

    /* Machine inspectable binary information */
    . = ALIGN(4);
    __binary_info_start = .;
    .binary_info :
    {
        KEEP(*(.binary_info.keep.*))
        *(.binary_info.*)
    } > RAM
    __binary_info_end = .;
    . = ALIGN(4);

    .data : {
        __data_start__ = .;
        INCLUDE gen.blinky.data.ld
        *(vtable)
        *(.data*)

        . = ALIGN(4);
        *(.after_data.*)

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__mutex_array_start = .);
        KEEP(*(SORT(.mutex_array.*)))
        KEEP(*(.mutex_array))
        PROVIDE_HIDDEN (__mutex_array_end = .);

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(SORT(.preinit_array.*)))
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
        *(SORT(.fini_array.*))
        *(.fini_array)
        PROVIDE_HIDDEN (__fini_array_end = .);

        *(.jcr)
        . = ALIGN(4);
        /* All data end */
        __data_end__ = .;
    } > RAM

    .uninitialized_data (NOLOAD): {
        . = ALIGN(4);
        *(.uninitialized_data*)
    } > RAM
    /* __etext is (for backwards compatibility) the name of the .data init source pointer (...) */
    __etext = LOADADDR(.data);

    /* Start and end symbols must be word-aligned */
    .scratch_x : {
        __scratch_x_start__ = .;
        *(.scratch_x.*)
        . = ALIGN(4);
        __scratch_x_end__ = .;
    } > SCRATCH_X
    __scratch_x_source__ = LOADADDR(.scratch_x);

    .scratch_y : {
        __scratch_y_start__ = .;
        *(.scratch_y.*)
        . = ALIGN(4);
        __scratch_y_end__ = .;
    } > SCRATCH_Y
    __scratch_y_source__ = LOADADDR(.scratch_y);

    .bss  : {
        . = ALIGN(4);
        __bss_start__ = .;
        INCLUDE gen.blinky.bss.ld
        *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss*)))
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    .shared : {
        INCLUDE gen.blinky.shared.ld
    } > RAM

    .heap (NOLOAD):
    {
        __end__ = .;
        end = __end__;
        __heap_start = .;
        KEEP(*(.heap*))
        __heap_end = .;
        __HeapLimit = .;
    } > RAM

    /* .stack*_dummy section doesn't contains any symbols. It is only
     * used for linker to calculate size of stack sections, and assign
     * values to stack symbols later
     *
     * stack1 section may be empty/missing if platform_launch_core1 is not used */

    /* by default we put core 0 stack at the end of scratch Y, so that if core 1
     * stack is not used then all of SCRATCH_X is free.
     */
    .stack1_dummy (NOLOAD):
    {
        *(.stack1*)
    } > SCRATCH_X
    .stack_dummy (NOLOAD):
    {
        KEEP(*(.stack*))
    } > SCRATCH_Y

    /* Publish FLASH size as a symbol accessible from C */
/*    __cmrx_flash_length = LENGTH(FLASH);
*/
    __cmrx_flash_length = LENGTH(RAM);

    /* stack limit is poorly named, but historically is maximum heap ptr */
    __StackLimit = ORIGIN(RAM) + LENGTH(RAM);
    __StackOneTop = ORIGIN(SCRATCH_X) + LENGTH(SCRATCH_X);
    __StackTop = ORIGIN(SCRATCH_Y) + LENGTH(SCRATCH_Y);
    __StackOneBottom = __StackOneTop - SIZEOF(.stack1_dummy);
    __StackBottom = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(__stack = __StackTop);

    /* Check if data + heap + stack exceeds RAM limit */
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed")

    ASSERT( __binary_info_header_end - __logical_binary_start <= 256, "Binary info must be in first 256 bytes of the binary")
    /* todo assert on extra code */
}

