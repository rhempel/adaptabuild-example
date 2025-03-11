/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_bss_start = .;
		build/blinky/max32690/dummy/dummy.a(.bss .bss.*)
		. = ALIGN(0x4);
		dummy_bss_end = .;
