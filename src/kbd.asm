bits 32

[section .text]

; Gets a keycode from the keyboard, returning it in al. Trashes ecx. If an
; invalid scancode was received, skips it.
global get_keycode
get_keycode.halt:
	sti
	hlt
get_keycode:
	cli
	mov ax, [keycode]
	mov byte [keycode+1], 0
	test ah, ah
	jz .halt
	sti
	ret

[section .data]

global keycode
keycode: dw 0

; vi: cc=80 ft=nasm
