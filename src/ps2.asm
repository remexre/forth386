bits 32

extern brk
extern idt_set

[section .text]

; Sets up the PS/2 port to be able to receive keyboard input.
global ps2_init
ps2_init:
	; Set IRQ1 handler.
	mov eax, 0x21
	mov ecx, ps2_irq
	call idt_set

	; Reenable IRQ1
	mov dx, 0x21
	in al, dx
	and al, 0b11111101
	out dx, al

	ret

; Busy-waits until we can write a command byte.
wait_until_input_buffer_empty:
	pause ; Can't hurt /shrug
	mov dx, 0x60
	in al, dx
	test al, 0x02
	jnz wait_until_input_buffer_empty
	ret

; The handler for the keyboard IRQ.
global ps2_irq
ps2_irq:
	mov dx, 0x60
	xor eax, eax
	in al, dx
	mov al, [keymap+eax]
	mov [0xb8000], al
	mov dx, 0x20
	mov al, 0x20
	out dx, al
	mov dword [esp], brk
	iret

[section .rodata]

keymap:
incbin "tmp/keymap.bin"
