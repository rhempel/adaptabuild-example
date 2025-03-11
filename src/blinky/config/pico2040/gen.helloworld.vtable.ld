/* Process name: init */
		. = ALIGN(0x4);
		init_vtable_start = .;
		libinit.a(.vtable .vtable.*)
		. = ALIGN(0x4);
		init_vtable_end = .;
