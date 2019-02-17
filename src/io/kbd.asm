bits 32

extern keycode_to_ascii

global get_ascii
global kbd_state
global keycode

[section .text]

; Gets an ASCII keystroke, retuning it in al. Trashes eax, ebx, ecx.
get_ascii:
	call update_kbd_state
	test al, 0x80
	jnz get_ascii

	call keycode_to_ascii
	test al, al
	jz get_ascii

	ret

; Gets an ASCII key and updates the kbd_state. Returns the keycode that caused
; the change in al. Trashes eax, ebx, ecx.
update_kbd_state:
	call get_keycode

	mov ah, al

	; ch = down
	; down = (n >> 7) != 0;
	mov ch, al
	shr ch, 7
	not ch

	; cl = bit
	; bit = n & 0x07;
	mov cl, al
	and cl, 0x07

	; ebx = byte
	; byte = (n >> 3) & 0x0f;
	xor ebx, ebx
	mov bl, al
	shr bl, 3
	and bl, 0x0f

	; al = *ptr
	; *ptr = kbd_state[byte];
	mov al, [kbd_state+ebx]

	test ch, 1
	jnz .else
.if:
	mov ch, 1
	shl ch, cl
	or al, ch
	mov [kbd_state+ebx], al
	mov al, ah
	ret
.else:
	mov ch, 1
	shl ch, cl
	not ch
	and al, ch
	mov [kbd_state+ebx], al
	mov al, ah
	ret

; Gets a keycode from the keyboard, returning it in al. If an invalid scancode
; was received, skips it. Trashes the rest of eax.
get_keycode:
	xor eax, eax
	jmp .entry
.halt:
	sti
	hlt
.entry:
	cli
	mov ax, [keycode]
	mov word [keycode], 0
	test ah, ah
	jz .halt
	sti
	ret

[section .bss]

keycode: resw 1

; Bitmap of keys, where 1 = down, 0 = up.
kbd_state: resb 16

; vi: cc=80 ft=nasm
