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

; Prints a string. The length is taken in ecx, and a pointer to the string data
; is taken in edi. Trashes eax, ebx, ecx, edx, edi.
global console_print_string
console_print_string:
	xor eax, eax ; Index into string
	xor edx, edx ; Index into console
	mov dx, [cursor]

.loop:
	cmp eax, ecx
	jae .end

	mov bl, [edi+eax]
	mov [console+edx], bl

	inc eax
	inc edx

	cmp edx, 80*24
	jl .loop

	call console_scroll
	sub edx, 80
	jmp .loop

.end:
	mov [cursor], dx
	ret

; Prints a newline to the console. Trashes eax, ecx, edi.
global console_print_newline
console_print_newline:
	mov cl, 80
	xor eax, eax
	mov ax, [cursor]
	div cl
	xor ah, ah
	inc al

	lea eax, [eax+eax*4]
	shl ax, 4
	mov [cursor], ax
	cmp ax, 80*24
	jae console_scroll
	ret

; Scrolls the console. Preserves all registers, and moves the cursor to the
; first row of the last line.
console_scroll:
	push eax
	push ecx
	push esi
	push edi

	mov esi, console+80
	mov edi, console
	mov ecx, 80*23
	mov [cursor], cx
	rep movsb

	mov ecx, 80
	mov al, ' '
	rep stosb

	pop edi
	pop esi
	pop ecx
	pop eax
	ret

[section .data]

numbuf_cap equ 10
numbuf:
.len: dd 0
.str: times numbuf_cap db '?'
.end:

; vi: cc=80 ft=nasm
