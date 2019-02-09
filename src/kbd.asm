bits 32

extern scancode_set_1

[section .text]

; Gets a keycode from the keyboard, returning it in al. Trashes ecx. If an
; invalid scancode was received, skips it.
global get_keycode
get_keycode:
	call get_scancode
	call scancode_set_1
	cmp al, 0x7f
	je get_keycode

; Gets a scancode from the keyboard, returning it in al. Trashes ecx.
get_scancode:
	xor ecx, ecx

.loop:
	mov cx, [scancode_buf.cursors]
	cmp cl, ch
	jnz .loop_end
	hlt
	jmp .loop

.loop_end:
	shr cx, 8
	mov al, [scancode_buf.bytes+ecx]

	inc cl
	and cl, 0x1f
	mov [scancode_buf.rdcursor], cl

	ret

[section .data]

global scancode_buf.bytes
global scancode_buf.wrcursor
scancode_buf:
.bytes: times 32 db 0
.cursors:
.wrcursor: db 0
.rdcursor: db 0

; vi: cc=80 ft=nasm
