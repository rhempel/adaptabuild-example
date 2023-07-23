MEMORY
{
  rom (rx)  : ORIGIN = 0x08000000, LENGTH = 64K
  ram (rwx) : ORIGIN = 0x20000000, LENGTH = 8K
}

_estack = ORIGIN(ram) + LENGTH(ram); /* ram end */

SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } > rom

/* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } > rom

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

 	.data : AT(_etext) /* LMA */
 	{
 		_sdata = .;
 		*(.data*)
 		_edata = .;
 
 	} > ram
 
 	.bss (NOLOAD):
 	{
 		_sbss = .;
 		*(.bss*)
 		*(COMMON)
 		_ebss = .;
 	} > ram
}