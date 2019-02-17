bits 32

extern console_init
extern gdt_init
extern idt_init
extern ps2_init

extern console_print_string
extern console_print_newline
extern console_refresh
extern ipb
extern repl

[section .text]

; The entry point to the kernel.
global start
start:
	; Store the address of the Multiboot2 structure.
	mov [ipb+4], ebx

	cld ; So string instructions increment esi.

	mov esp, param_stack_top
	mov ebp, return_stack_top

	call gdt_init
	call idt_init
	call console_init
	call ps2_init

	mov esi, .halt

.halt:
	call console_print_newline
	mov ecx, 10
	mov edi, .halt_str
	call console_print_string
	call console_print_newline
	call console_refresh
	cli
	hlt
.halt_str: db "Halting..."

[section .param_stack nobits]

global param_stack_top
param_stack: resb 0x100000
param_stack_top:

[section .return_stack nobits]

global return_stack_top
return_stack: resb 0x100000
return_stack_top:

; vi: cc=80 ft=nasm
