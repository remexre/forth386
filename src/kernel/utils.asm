bits 32

extern color
extern console_print_newline
extern console_print_string
extern console_refresh
extern forth_base
extern forth_dictionary
extern forth_error_handler
extern forth_quit.cfa
extern parse_string

global capitalize
global contains
global enter
global error_missing_name
global error_stack_underflow
global find
global illegal_division
global is_number
global panic
global parse_number
global read_to_quote
global word_not_found

%include "src/kernel/common.inc"

[section .enter]

enter:
	; Push IP to the Return Stack
	sub ebp, 4
	mov [ebp], esi
	; Make IP point to the Parameter Field
	lea esi, [eax+JMP_LEN]
	NEXT

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

error_missing_name:
	xor eax, eax
	inc eax
	push eax
	mov eax, [forth_error_handler]
	jmp eax

error_stack_underflow:
	xor eax, eax
	add eax, 2
	push eax
	mov eax, [forth_error_handler]
	jmp eax

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
	jb .minus
	cmp al, "%"
	ja .minus
	inc edx

	; Check for a leading `-`.
.minus:
	mov al, [edi+edx]
	cmp al, '-'
	jne .loop

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

.minus:
	mov dl, [edi]
	cmp dl, '-'
	mov byte [negative], 0
	jne .loop
	inc bx
	mov byte [negative], 1

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
	mov dl, [negative]
	test dl, dl
	jz .early_done
	neg eax
.early_done:
	ret

.decimal:
	mov dword [forth_base], 10
	inc ebx
	jmp .minus
.hex:
	mov dword [forth_base], 16
	inc ebx
	jmp .minus
.binary:
	mov dword [forth_base], 2
	inc ebx
	jmp .minus

; The handler for something going very wrong.
panic:
	mov edi, .str
	mov ecx, 34
	call console_print_string
	call console_print_newline
	mov byte [color], 0x4e
	call console_refresh
.loop:
	int3
	hlt
	jmp .loop
.str: db "Something's gone horribly wrong..."

; Reads until a word containing a " character is found. Returns up until (but
; not including) the " character. Returns the length in ecx, and the start in
; edi.
read_to_quote:
	call parse_string
	push edi

.loop:
	lea edx, [edi+ecx]
	test ecx, ecx
	jz .end

	mov al, '"'
	repne scasb
	jz .end_quote

	call parse_string
	jmp .loop

.end_quote:
	sub edx, ecx
	dec edx
.end:
	pop edi
	mov ecx, edx
	sub ecx, edi
	ret

; The word-not-found handler.
word_not_found:
	push ecx
	push edi
	mov edi, .str
	mov ecx, 16
	call console_print_string
	pop edi
	pop ecx
	call console_print_string
	call console_print_newline
	call console_refresh
	NEXT
.str: db "Word not found: "

[section .bss]

stored_esi: resd 1
stored_edi: resd 1
stored_cl: resb 1
negative: resb 1

; vi: cc=80 ft=nasm
