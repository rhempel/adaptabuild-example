/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_bss_start = .;
		build/blinky/STM32G031xx/dummy/dummy.a(.bss .bss.*)
		. = ALIGN(0x4);
		dummy_bss_end = .;
