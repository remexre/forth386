bits 32

extern color
extern console
extern cursor

[section .text]

; Prints the number in eax to the console. Trashes eax, ebx, ecx, edx, edi.
global console_print_number
console_print_number:
	; Clear numbuf.
	mov dword [numbuf.str], '????'
	mov dword [numbuf.str+4], '????'
	mov word [numbuf.str+8], '??'

	mov ecx, 10
	mov edi, numbuf.end - 1
	mov dword [numbuf.len], 0

.loop:
	test eax, eax
	jz .loop_exit
	xor edx, edx
	div ecx
	add dl, 0x30
	mov [edi], dl
	dec edi
	inc dword [numbuf.len]
	test eax, eax
	jmp .loop
.loop_exit:

	mov eax, numbuf.len

	; Move up the thing we just printed.
	mov ecx, numbuf_cap
	sub ecx, [numbuf.len]
	lea esi, [numbuf.str+ecx]
	mov edi, numbuf.str
	rep movsb

	; Tail call -- since we precede console_print_string, we can drop this
	; instruction.
	; jmp console_print_string

; Prints a string. The argument is taken in eax, and is a pointer to a dword
; length, followed by that many bytes of string data. Trashes eax, ebx, ecx,
; edx, edi.
global console_print_string
console_print_string:
	xor edx, edx
	mov dx, [cursor]
	mov ecx, [eax]
	test ecx, ecx
	jz .end
	xor edi, edi

.loop:
	test cx, cx
	jz .end
	dec cx
	mov bl, [eax+4+edi]
	mov [console+edx], bl
	inc edi
	inc dx
	cmp dx, 80*25
	jne .loop

	push esi
	push edi
	push ecx

	sub dx, 80
	mov ecx, 80*24
	mov esi, console+80
	mov edi, console
	rep movsb

	pop ecx
	pop edi
	pop esi
	jmp .loop

.end:
	mov [cursor], dx
	ret

; Prints a space to the console. Trashes eax, ebx, ecx, edx, edi.
global console_print_space
console_print_space:
	mov eax, space
	jmp console_print_string

; Prints a newline to the console. Trashes eax, ecx, edi.
global console_print_newline
console_print_newline:
	mov cx, 80
	mov ax, [cursor]
	div cl
	sub cl, ah

	mov ax, [cursor]
	add ax, cx
	cmp ax, 80*25
	jl .skip_scroll

	sub ax, cx
	push esi
	mov ecx, 80*24
	mov esi, console+80
	mov edi, console
	rep movsb
	; TODO Clear last line
	pop esi

.skip_scroll:
	mov [cursor], ax
	ret

[section .data]

numbuf_cap equ 10
numbuf:
.len: dd 0
.str: times numbuf_cap db '?'
.end:

[section .rodata]

space:
.len: dd 1
.str: db ' '
