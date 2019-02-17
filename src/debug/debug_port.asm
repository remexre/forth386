bits 32

global debug_port_write_byte
global debug_port_write_string

[section .text]

; Takes in byte in al.
debug_port_write_byte:
	push eax
	push ecx
	push edx

	xor ecx, ecx
	mov cl, al
	and cl, 0x0f
	mov dh, [hex_chars+ecx]
	mov cl, al
	shr cl, 4
	mov dl, [hex_chars+ecx]

	mov ax, dx
	mov dx, 0xe9
	out dx, al
	shr ax, 8
	out dx, al
	mov al, 10
	out dx, al

	pop edx
	pop ecx
	pop eax
	ret

; Takes in addr in eax
debug_port_write_string:
	push eax
	push ecx
	push edx

	mov ecx, eax

.loop:
	mov al, [ecx]
	test al, al
	jz .end

	mov dx, 0xe9
	out dx, al
	inc ecx
	jmp .loop

.end:
	pop edx
	pop ecx
	pop eax
	ret

[section .rodata]

hex_chars: db "0123456789abcdef"

; vi: cc=80 ft=nasm
