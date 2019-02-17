bits 32

extern console_init
extern gdt_init
extern idt_init
extern ps2_init

extern cold.cfa
extern console_print_string
extern console_print_newline
extern console_refresh
extern ipb
extern repl

global halt
global param_stack_top
global return_stack_top
global start

[section .text]

; The entry point to the kernel.
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

	mov esi, halt
	jmp cold.cfa

halt:
	call console_print_newline
	mov ecx, 10
	mov edi, .str
	call console_print_string
	call console_print_newline
	call console_refresh
	cli
	hlt
.str: db "Halting..."

[section .param_stack nobits]

param_stack: resb 0x100000
param_stack_top:

[section .return_stack nobits]

return_stack: resb 0x100000
return_stack_top:

; vi: cc=80 ft=nasm
