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

; Lookup tables for ASCII characters. The characters are the printables, plus:
;   0x00 for keys that don't generate a character
;   0x08 for backspace
;   0x09 for tab
;   0x0a for enter
;   0x1b for escape
;   0x7f for delete
lookup:
	; Lowercase, Row 0
	times 4 db 0
	db ' '
	times 11 db 0
	; Lowercase, Row 1
	db 0, 'zxcvbnm,./'
	times 5 db 0
	; Lowercase, Row 2
	db 0, "asdfghjkl;'", 0x0a
	times 3 db 0
	; Lowercase, Row 3
	db 0x09, 'qwertyuiop[]\'
	times 2 db 0
	; Lowercase, Row 4
	db '`1234567890-=', 0x08
	times 2 db 0
	; Lowercase, Row 5
	times 12 db 0
	db 0x7f
	times 3 db 0
	; Lowercase, Row 6
	db 0x1b
	times 15 db 0
	; Lowercase, Row 7
	times 16 db 0
	; Uppercase, Row 0
	times 4 db 0
	db ' '
	times 11 db 0
	; Uppercase, Row 1
	db 0, 'ZXCVBNM<>?'
	times 5 db 0
	; Uppercase, Row 2
	db 0, 'ASDFGHJKL:"', 0x0a
	times 3 db 0
	; Uppercase, Row 3
	db 0x09, 'QWERTYUIOP{}|'
	times 2 db 0
	; Uppercase, Row 4
	db '~!@#$%^&*()_+', 0x08
	times 2 db 0
	; Uppercase, Row 5
	times 12 db 0
	db 0x7f
	times 3 db 0
	; Uppercase, Row 6
	db 0x1b
	times 15 db 0
	; Uppercase, Row 7
	times 16 db 0

%if ($ - lookup) != 256
%error "lookup table of wrong length"
%endif

; vi: cc=80 ft=nasm
