/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_bss_start = .;
		build/blinky/pico2040/dummy/dummy.a(.bss .bss.*)
		. = ALIGN(0x4);
		dummy_bss_end = .;
