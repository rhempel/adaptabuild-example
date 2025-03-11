/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_text_start = .;
		build/blinky/STM32H7A3ZI/dummy/dummy.a(.text .text.*)
        . = ALIGN(0x4);
		dummy_text_end = .;
