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

	. = 2M;
	.bss : {
		*(.bss)
	}
}
