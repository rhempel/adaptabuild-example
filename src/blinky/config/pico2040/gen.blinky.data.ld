/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_data_start = .;
		build/blinky/pico2040/dummy/dummy.a(.data .data.*)
		. = ALIGN(0x4);
		dummy_data_end = .;
