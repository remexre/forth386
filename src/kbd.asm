bits 32

%include "src/debug.inc"

[section .text]

; Gets a keycode from the keyboard, returning it in al. Trashes ecx. If an
; invalid scancode was received, skips it.
global get_keycode
get_keycode:
	jmp .entry
.halt:
	debug "[kbd ] about to halt"
	sti
	hlt
.entry:
	cli
	mov ax, [keycode]
	mov byte [keycode+1], 0
	test ah, ah
	jz .halt
	sti
	debug "[kbd ] got keycode"
	ret

[section .data]

global keycode
keycode: dw 0

; vi: cc=80 ft=nasm
