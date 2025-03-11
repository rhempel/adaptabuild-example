/* Process name: dummy */
		. = ALIGN(0x4);
		dummy_text_start = .;
		build/blinky/STM32G031xx/dummy/dummy.a(.text .text.*)
        . = ALIGN(0x4);
		dummy_text_end = .;
