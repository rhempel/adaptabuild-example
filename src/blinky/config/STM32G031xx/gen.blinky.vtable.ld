/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_vtable_start = .;
		build/blinky/STM32G031xx/dummy/dummy.a(.vtable .vtable.*)
		. = ALIGN(0x4);
		dummy_vtable_end = .;
