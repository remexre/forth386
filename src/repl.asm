bits 32

extern console
extern cursor
extern console_print_newline
extern console_print_string
extern console_refresh
extern get_ascii
extern parsed_string.len
extern parsed_string.ptr

[section .text]

; The REPL's entry point.
global repl
repl:
.loop:
	call read_line

	mov ecx, 3
	mov edi, strs.ok
	call console_print_string
	call console_print_newline

	jmp .loop

; Reads a line.
read_line:
	mov dx, [cursor]
	mov [out_cursor], dx

	mov word [console+80*24], '>'
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

	mov edi, console+80*24+2
	sub ecx, 80*24+2
	mov [parsed_string.len], ecx
	mov [parsed_string.ptr], edi

	jmp console_print_string

; The handler for the Pause/Break key. When that key is pressed, this function
; is jumped to.
global brk
brk:
	int3
	jmp repl

[section .bss]

out_cursor: resw 1

[section .rodata]

strs:
.ok: db " ok"

; vi: cc=80 ft=nasm
