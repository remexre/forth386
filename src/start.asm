bits 32
extern console_init

[section .text]

; The entry point to the kernel.
global start
start:
	cld ; So lodsd increments esi.

	mov esp, param_stack_top
	mov ebp, return_stack_top

	call console_init

; Halts the CPU.
halt:
	cli
	hlt
	jmp halt

foo: db "Hello, world!"

[section .bss]

bss_start:

param_stack: resd 64
param_stack_top:

return_stack: resd 64
return_stack_top:

heap: resb $-bss_start
