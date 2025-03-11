/* Process name: init */
		. = ALIGN(0x4);
		init_shared_start = .;
		libinit.a(.shared .shared.*)
		. = ALIGN(0x4);
		init_shared_end = .;
