/* Process name: init */
		. = ALIGN(0x4);
		init_text_start = .;
		libinit.a(.text .text.*)
		. = ALIGN(0x4);
		init_text_end = .;
