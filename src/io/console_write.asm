bits 32

extern console
extern cursor
extern forth_base

global console_print_newline
global console_print_number
global console_print_string

[section .text]

; Prints the number in eax to the console in the base specified in forth_base.
; Trashes eax, ebx, ecx, edx, edi.
console_print_number:
	test eax, eax
	jz .zero

	xor ecx, ecx

	; Put the reversed string into numbuf.
.fill_loop:
	xor edx, edx
	div dword [forth_base]
	mov dl, [number_map+edx]
	mov [numbuf+ecx], dl
	inc ecx

	test eax, eax
	jnz .fill_loop

	; Reverse the string.
	xor ebx, ebx
	mov edx, 31
.rev_loop:
	mov al, [numbuf+ebx]
	xchg [numbuf+edx], al
	mov [numbuf+ebx], al
	inc ebx
	dec edx
	cmp ebx, ecx
	jne .rev_loop

	lea edi, [numbuf+edx+1]
	jmp console_print_string

.zero:
	mov edi, .zero_str
	mov ecx, 1
	jmp console_print_string
.zero_str: db "0"

; Prints a string. The length is taken in ecx, and a pointer to the string data
; is taken in edi. Trashes eax, ebx, ecx, edx, edi.
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
	mov al, " "
	rep stosb

	pop edi
	pop esi
	pop ecx
	pop eax
	ret

[section .rodata]

number_map: db "0123456789abcdef"

[section .bss]

numbuf: resb 32

; vi: cc=80 ft=nasm
