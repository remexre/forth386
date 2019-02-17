bits 32

extern forth_base
extern forth_to_in

[section .text]

; Parses a string out of the input buffer. Returns the length in ecx, and a
; pointer to the string data in edi.
global parse_string
parse_string:
	mov ecx, [forth_to_in]
	mov edx, ecx
	cmp ecx, [input_len]
	jne .skip_delims

	xor ecx, ecx
	ret

.skip_delims:
	mov al, [input_buf+ecx]
	call is_delim
	test al, al
	jz .accept

	inc dword [forth_to_in]
	jmp parse_string

.accept:
	cmp ecx, [input_len]
	je .done
	mov al, [input_buf+ecx]
	call is_delim
	test al, al
	jne .done

	inc ecx
	jmp .accept

.done:
	mov [forth_to_in], ecx
	sub ecx, edx
	lea edi, [input_buf+edx]
	ret

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

[section .bss]

global input_len
input_len: resd 1
global input_buf
input_buf: resb 80

; vi: cc=80 ft=nasm
