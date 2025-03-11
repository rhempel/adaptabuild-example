/* Process name: init */
		. = ALIGN(0x4);
		init_bss_start = .;
		libinit.a(.bss .bss.*)
		. = ALIGN(0x4);
		init_bss_end = .;
