bits 32

%include "src/debug.inc"

extern kbd_state

[section .text]

; Converts a keycode in al to an ASCII character. Returns the ASCII character
; in al, or 0x00 if there is no corresponding character. Trashes eax, ebx, ecx.
global keycode_to_ascii
keycode_to_ascii:
	and al, 0x7f

	mov cx, [kbd_state+2]
	test cx, 0x0801
	jz .skip_shift
	or al, 0x80
.skip_shift:

	mov ebx, lookup
	xlatb
	ret

[section .rodata]

; Lookup tables for ASCII characters.
lookup:
	; Lowercase, Row 0
	times 4 db 0
	db ' '
	times 11 db 0
	; Lowercase, Row 1
	db 0, 'zxcvbnm,./'
	times 5 db 0
	; Lowercase, Row 2
	db 0, "asdfghjkl;'", 10
	times 3 db 0
	; Lowercase, Row 3
	db 9, 'qwertyuiop[]\'
	times 2 db 0
	; Lowercase, Row 4
	db '`1234567890-=', 8
	times 2 db 0
	; Lowercase, Row 5-7
	times (3*16) db 0
	; Uppercase, Row 0
	times 4 db 0
	db ' '
	times 11 db 0
	; Uppercase, Row 1
	db 0, 'ZXCVBNM<>?'
	times 5 db 0
	; Uppercase, Row 2
	db 0, 'ASDFGHJKL:"', 10
	times 3 db 0
	; Uppercase, Row 3
	db 9, 'QWERTYUIOP{}|'
	times 2 db 0
	; Uppercase, Row 4
	db '~!@#$%^&*()_+', 8
	times 2 db 0
	; Uppercase, Row 5-7
	times (3*16) db 0

%if ($ - lookup) != 256
%error "lookup table of wrong length"
%endif

; vi: cc=80 ft=nasm
