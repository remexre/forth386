ENTRY(start)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
	. = 1M;
	.loader : {
		KEEP(*(.multiboot2_header))
	}
	.forth386 : {
		*(.text)
		*(.forthk)
		*(.forthl)
		*(.data)
		*(.rodata)
		*(.bss)
	}

	. = 0x123456;
	.ipb : {
		/* The "Important Pointer Block" */
		KEEP(*(.ipb))
	}
	.startup : { KEEP(*(.startup)) }

	. = 2M;
	.params_stack : { *(.bss.params) }

	. = 3M;
	.return_stack : { *(.bss.return) }

	top = .;
}
