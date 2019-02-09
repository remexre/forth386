bits 32

extern brk
extern idt_set
extern keycode
extern scancode_set_1

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
	and al, 11111101b
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
ps2_irq:
.loop:
	mov dx, 0x64
	in al, dx

	test al, 1
	jz .end

	mov dx, 0x60
	in al, dx

	call scancode_set_1
	mov ah, al
	and ah, 0x7f
	cmp ah, 0x7f
	je .loop

	mov ah, 0x01
	mov [keycode], ax

.end:
	mov dx, 0x20
	mov al, 0x20
	out dx, al
	iret

; vi: cc=80 ft=nasm
