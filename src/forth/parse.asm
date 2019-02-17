bits 32

extern forth_base
extern forth_to_in

global parse_string
global set_parse_buffer

[section .text]

; Parses a string out of the input buffer. Returns the length in ecx, and a
; pointer to the string data in edi.
parse_string:
	mov edi, [input_buf]
	mov ecx, [forth_to_in]
	mov edx, ecx

.skip_delims:
	cmp ecx, [input_len]
	je .zero

	mov al, [edi+ecx]
	call is_delim
	test al, al
	jz .check_for_comment

	inc ecx
	jmp .skip_delims

.check_for_comment:
	mov al, [edi+ecx]
	cmp al, '\'
	je .skip_comment

	mov edx, ecx

.accept:
	cmp ecx, [input_len]
	je .done
	mov al, [edi+ecx]
	call is_delim
	test al, al
	jne .done

	inc ecx
	jmp .accept

.done:
	mov [forth_to_in], ecx
	sub ecx, edx
	add edi, edx
	ret

.zero:
	xor ecx, ecx
	ret

.skip_comment:
	inc ecx

	cmp ecx, [input_len]
	je .zero

	mov al, [edi+ecx]
	cmp al, 0x0a
	je .skip_delims

	jmp .skip_comment

; Checks if the byte in al is a delimiter. Returns 1 in al if it is, or 0 if it
; is not.
is_delim:
	push ebx

	cmp al, 0
	sete bl

	cmp al, 0x09
	sete ah
	or bl, ah

	cmp al, 0x0a
	sete ah
	or bl, ah

	cmp al, 0x20
	sete al
	or al, bl

	pop ebx
	ret

; Sets the buffer to parse from. The buffer's address should be in edi, and its
; length in ecx. Does not modify any registers.
set_parse_buffer:
	mov [input_buf], edi
	mov [input_len], ecx
	mov dword [forth_to_in], 0
	ret

[section .bss]

input_buf: resd 1
input_len: resd 1

; vi: cc=80 ft=nasm
