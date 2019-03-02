bits 32

extern console_init
extern gdt_init
extern idt_init
extern ps2_init

extern cold
extern color
extern console_print_string
extern console_print_newline
extern console_refresh
extern ipb
extern repl

global default_param_stack_top
global default_return_stack_top
global halt
global start

[section .text]

; The entry point to the kernel.
start:
	; Store the address of the Multiboot2 structure.
	mov [ipb+4], ebx

	cld ; So string instructions increment esi.

	mov esp, default_param_stack_top
	mov ebp, default_return_stack_top

	call gdt_init
	call idt_init
	call console_init
	call ps2_init

	mov esi, halt.nomsg
	jmp cold

halt:
	push edi
.loop:
	mov byte [color], 0x4e
	mov edi, [esp]
	test edi, edi
	jnz .with_message
	mov ecx, 10
	mov edi, .str_halting_ellipsis
	call console_print_string
	jmp .continue
.with_message:
	mov ecx, 9
	mov edi, .str_halting_paren
	call console_print_string
	mov edi, [esp]
	xor eax, eax
	xor ecx, ecx
	dec ecx
	repnz scasb
	sub edi, [esp]
	lea ecx, [edi-1]
	mov edi, [esp]
	call console_print_string
	mov ecx, 4
	mov edi, .str_close_ellipsis
	call console_print_string
.continue:
	call console_print_newline
	call console_refresh
	cli
	hlt
	jmp .loop
.nomsg:
	xor edi, edi
	jmp halt
.str_close_ellipsis: db ")..."
.str_halting_ellipsis: db "Halting..."
.str_halting_paren: db "Halting ("

[section .param_stack nobits]

resb 0x40000
default_param_stack_top:

[section .return_stack nobits]

resb 0x40000
default_return_stack_top:

[section .heap nobits]

resb 0x80000

; vi: cc=80 ft=nasm
