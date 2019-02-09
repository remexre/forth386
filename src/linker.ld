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
	}
	.bss : {
		*(.bss)
	}

	. = 0x102030;
	.ipb : {
		/* The "Important Pointer Block" */
		KEEP(*(.data.ipb))
	}

	top = .;
}
