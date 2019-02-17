bits 32

extern forth_base
extern forth_dictionary

global capitalize
global find
global is_number
global parse_number

[section .text]

; Capitalizes the string whose length is in ecx, and whose contents are pointed
; to by edi. Trashes eax, edx.
capitalize:
	xor edx, edx
.loop:
	cmp ecx, edx
	je .done

	mov al, [edi+edx]
	cmp al, "a"
	jb .next
	cmp al, "z"
	ja .next

	and byte [edi+edx], 0xdf

.next:
	inc edx
	jmp .loop

.done:
	ret

; Finds the non-smudged word with the given name. The length of the string to
; find should be in ecx, and a pointer to its data should be in edi. Returns
; the address of the header in eax, or 0 if it was not found.
find:
	test ecx, 0xffffff00
	jnz .fail

	mov [stored_cl], cl
	mov [stored_esi], esi
	mov [stored_edi], edi
	mov eax, [forth_dictionary]

.loop:
	test eax, eax
	jz .done

	test byte [eax+4], 0x02
	jnz .next

	cmp cl, [eax+5]
	jne .next

	lea esi, [eax+6]
	repe cmpsb
	mov edi, [stored_edi]
	mov cl, [stored_cl]
	je .done

.next:
	mov eax, [eax]
	jmp .loop

.fail:
	xor eax, eax
.done:
	mov esi, [stored_esi]
	ret

; Returns whether the string whose length is in ecx and whose contents are
; pointed to by edi is a valid number. If it is, eax will be 1, otherwise it
; will be zero. Trashes edx.
;
; NOTE: This is currently overly permissive... For example, %2 is a valid
; number, although % implies that the number should be binary. This is because
; this function is indifferent to the current base.
is_number:
	xor eax, eax
	inc ah
	xor edx, edx

	; Check that the string is of nonzero length.
	cmp ecx, edx
	je .done

	; Check for a leading `#`, `$`, or `%`.
	mov al, [edi+edx]
	cmp al, "#"
	jb .loop
	cmp al, "%"
	ja .loop

.loop_next:
	inc edx
.loop:
	; Check that the string is of nonzero length.
	cmp ecx, edx
	je .done

	mov al, [edi+edx]

	; Check if the character is between `0-9`. If so, go to .loop_next, ...
	cmp al, "0"
	jb .check_af
	cmp al, "9"
	ja .check_af
	jmp .loop_next

	; ...if not, check if it's between `A-F`. If so, go to .loop_next.
.check_af:
	cmp al, "A"
	jb .fail
	cmp al, "F"
	ja .fail
	jmp .loop_next

	; Otherwise, fail out.
.fail:
	xor ah, ah
.done:
	mov al, ah
	and eax, 0xff
	ret

; Parses a string that is_number returned 1 for into a number in the base
; specified in forth_base. Returns the number in eax. Trashes ebx, edx.
parse_number:
	xor eax, eax
	test ecx, ecx
	jz .early_done
	xor edx, edx
	xor ebx, ebx
	push dword [forth_base]

	mov dl, [edi]
	cmp dl, "#"
	je .decimal
	cmp dl, "$"
	je .hex
	cmp dl, "%"
	je .binary
	jmp .loop

.loop:
	cmp ecx, ebx
	je .done

	mul dword [forth_base]

	mov dl, [edi+ebx]
	cmp dl, "0"
	jb .loop_af
	cmp dl, "9"
	ja .loop_af

	sub dl, "0"
	jmp .loop_next

.loop_af:
	sub dl, "A"-10

.loop_next:
	add eax, edx
	inc ebx
	jmp .loop

.done:
	pop dword [forth_base]
.early_done:
	ret

.decimal:
	mov dword [forth_base], 10
	xor edx, edx
	jmp .loop_next
.hex:
	mov dword [forth_base], 16
	xor edx, edx
	jmp .loop_next
.binary:
	mov dword [forth_base], 2
	xor edx, edx
	jmp .loop_next

[section .bss]

stored_esi: resd 1
stored_edi: resd 1
stored_cl: resb 1

; vi: cc=80 ft=nasm
