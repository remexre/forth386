bits 32

extern console
extern cursor
extern console_print_newline
extern console_print_string
extern console_refresh
extern get_ascii

[section .text]

; The main loop of the REPL.
global repl
repl:
	sti
	mov word [cursor], 80*24+2
	mov al, ' '
	mov ecx, 80*24
	mov edi, console
	rep stosb
	mov word [edi], '> '

.loop:
	call console_refresh
	call get_ascii

	xor ecx, ecx
	mov cx, [cursor]

	cmp al, 0x00 ; Null
	je .loop

	cmp al, 0x09 ; Tab
	je .loop

	cmp al, 0x1b ; Escape
	je .loop

	cmp al, 0x7f ; Delete
	je .loop

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
	test cx, cx
	jz .loop

	dec cx
	mov byte [console+ecx], 0
	mov [cursor], cx
	jmp .loop

.enter:
	mov dx, [out_cursor]
	mov [cursor], dx

	mov edi, console+80*24
	call console_print_string
	call console_print_newline

	mov dx, [cursor]
	mov [out_cursor], dx

	mov word [cursor], 80*24+2
	xor eax, eax
	mov ecx, 79
	mov edi, console+80*24+1
	rep stosb

	jmp .loop

; The handler for the Pause/Break key. When that key is pressed, this function
; is jumped to.
global brk
brk:
	int3
	jmp repl.loop

[section .data]

out_cursor: dw 0

; vi: cc=80 ft=nasm
