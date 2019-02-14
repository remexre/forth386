[section .multiboot2_header]

multiboot2_magic equ 0xe85250d6

multiboot2_header:
	dd multiboot2_magic ; Multiboot 2 Magic Number
	dd 0                ; i386 Protected Mode
	dd multiboot2_len   ; Header Length
	dd 0x100000000 - (multiboot2_magic + multiboot2_len)

multiboot2_tags:
	.end_tag:
		align 8
		dw 0 ; Type = End
		dw 0 ; Flags = {}
		dd 8 ; Size = 8

multiboot2_len EQU $ - multiboot2_header

; vi: cc=80 ft=nasm
