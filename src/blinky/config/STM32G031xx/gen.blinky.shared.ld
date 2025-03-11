/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_shared_start = .;
		build/blinky/STM32G031xx/dummy/dummy.a(.shared .shared.*)
		. = ALIGN(0x4);
		dummy_shared_end = .;
		