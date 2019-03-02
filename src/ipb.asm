bits 32

extern brk
extern color
extern console
extern cursor
extern default_param_stack_top
extern default_return_stack_top
extern idt

global ipb
global ipb.param_stack_top
global ipb.return_stack_top

[section .ipb]

; The Important Pointer Block.
ipb:
	db "I", "P", "B", 0x00
	dd 0 ; Gets filled in with address of multiboot2 information structure.
	dd console
	dd cursor
	dd color
	dd idt
.param_stack_top:  dd default_param_stack_top
.return_stack_top: dd default_return_stack_top

; vi: cc=80 ft=nasm
