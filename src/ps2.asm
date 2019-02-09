bits 32

extern brk
extern idt_set
extern scancode_buf.bytes
extern scancode_buf.wrcursor

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

	xor edx, edx
	mov dl, [scancode_buf.wrcursor]
	mov [scancode_buf.bytes+edx], al
	inc dl
	and dl, 0x1f
	mov [scancode_buf.wrcursor], dl

	mov dx, 0x64
	in al, dx
	test al, 0x01
	jnz ps2_irq

	mov dx, 0x20
	mov al, 0x20
	out dx, al

	iret

; vi: cc=80 ft=nasm
