/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_data_start = .;
		build/blinky/max32690/dummy/dummy.a(.data .data.*)
		. = ALIGN(0x4);
		dummy_data_end = .;
