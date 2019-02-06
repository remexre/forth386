ENTRY(start)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
	. = 1M;
	.loader : {
		KEEP(*(.multiboot2_header))
	}
	.text : {
		*(.text)
		*(.forthk)
		*(.forthl)
	}

	. = 2M;
	.bss : {
		*(.bss)
	}
}
