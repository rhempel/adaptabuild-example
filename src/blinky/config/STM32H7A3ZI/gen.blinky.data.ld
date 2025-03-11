/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_data_start = .;
		build/blinky/STM32H7A3ZI/dummy/dummy.a(.data .data.*)
		. = ALIGN(0x4);
		dummy_data_end = .;
