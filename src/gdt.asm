bits 32

[section .text]

; Sets up the GDT. Trashes eax.
global gdt_init
gdt_init:
	lgdt [gdtr]

	jmp 0x08:.reload_cs
.reload_cs:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	ret

[section .data]

gdtr:
.size:   dw gdt_len
.offset: dd gdt

%macro gdt_entry 3 ; base, limit, type (access byte)
	db ( %2        & 0xff)
	db ((%2 >>  8) & 0xff)
	db ( %1        & 0xff)
	db ((%1 >>  8) & 0xff)
	db ((%1 >> 16) & 0xff)
	db %3
	db ((%2 >> 16) & 0x0f) | 0xc0
	db ((%1 >> 24) & 0xff)
%endmacro

gdt:
.null: gdt_entry 0, 0,       0
.code: gdt_entry 0, 0xfffff, 0x9a
.data: gdt_entry 0, 0xfffff, 0x92
gdt_len equ ($ - gdt)

; vi: cc=80 ft=nasm
