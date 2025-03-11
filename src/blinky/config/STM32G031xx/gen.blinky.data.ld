/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_data_start = .;
		build/blinky/STM32G031xx/dummy/dummy.a(.data .data.*)
		. = ALIGN(0x4);
		dummy_data_end = .;
