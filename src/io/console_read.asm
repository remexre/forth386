bits 32

extern console
extern cursor
extern console_print_string
extern console_refresh
extern get_ascii
extern set_parse_buffer

global console_read_line

[section .text]

; Reads a line.
console_read_line:
	mov dx, [cursor]
	cmp dx, 80*24
	jb .skip_cursor_reset
	xor dx, dx
.skip_cursor_reset:
	mov [out_cursor], dx

	mov word [console+80*24], 0x10
	mov word [cursor], 80*24+2
	xor eax, eax
	mov ecx, 79
	mov edi, console+80*24+1
	rep stosb

.loop:
	call console_refresh
	call get_ascii

	xor ecx, ecx
	mov cx, [cursor]

	cmp al, 0x00 ; Null
	je .loop ; Ignore

	cmp al, 0x09 ; Tab
	je .loop ; Ignore

	cmp al, 0x1b ; Escape
	je .loop ; Ignore

	cmp al, 0x7f ; Delete
	je .loop ; Ignore

	cmp al, 0x08 ; Backspace
	je .bkspc

	cmp al, 0x0a ; Enter
	je .enter

	; Normal character
	cmp cx, 80*24+79
	jae .loop
	mov [console+ecx], al
	inc word [cursor]

	jmp .loop

.bkspc:
	cmp cx, 80*24+2
	jbe .loop

	dec cx
	mov byte [console+ecx], 0
	mov [cursor], cx
	jmp .loop

.enter:
	mov dx, [out_cursor]
	mov [cursor], dx

	mov word [console+80*24], 0x11
	sub ecx, 80*24+2
	mov edi, console+80*24+2
	call set_parse_buffer
	jmp console_print_string

[section .bss]

out_cursor: resw 1

; vi: cc=80 ft=nasm
