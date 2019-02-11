extern brk
extern console
extern cursor
extern color
extern idt

[section .ipb]

; The Important Pointer Block.
global ipb
ipb:
	db 'I', 'P', 'B', 0x00
	dd 0 ; Gets filled in with address of multiboot2 information structure.
	dd console
	dd cursor
	dd color
	dd idt
	dd brk

; vi: cc=80 ft=nasm
