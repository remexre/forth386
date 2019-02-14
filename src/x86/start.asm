bits 32

extern console_init
extern gdt_init
extern idt_init
extern ps2_init

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

	jmp repl

[section .startup]

incbin "src/startup.f"

[section .bss.params]

param_stack: resd 64
param_stack_top:

[section .bss.return]

return_stack: resd 64
return_stack_top:

; vi: cc=80 ft=nasm
