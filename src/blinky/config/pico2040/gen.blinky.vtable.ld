/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_vtable_start = .;
		build/blinky/pico2040/dummy/dummy.a(.vtable .vtable.*)
		. = ALIGN(0x4);
		dummy_vtable_end = .;
