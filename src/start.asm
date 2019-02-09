bits 32

extern console_init
extern gdt_init
extern idt_init
extern ps2_init
extern repl

[section .text]

; The entry point to the kernel.
global start
start:
	cld ; So lodsd increments esi.

	mov esp, param_stack_top
	mov ebp, return_stack_top

	call gdt_init
	call idt_init
	call console_init
	call ps2_init

	jmp repl

[section .bss]

bss_start:

param_stack: resd 64
param_stack_top:

return_stack: resd 64
return_stack_top:

heap: resb $-bss_start
