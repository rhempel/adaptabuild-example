/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_shared_start = .;
		build/blinky/max32690/dummy/dummy.a(.shared .shared.*)
		. = ALIGN(0x4);
		dummy_shared_end = .;
		