/* Process name: init */
		. = ALIGN(0x4);
		init_data_start = .;
		libinit.a(.data .data.*)
		. = ALIGN(0x4);
		init_data_end = .;
