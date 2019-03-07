bits 32

extern capitalize
extern find
extern forth_heap
extern forth_literal_impl.cfa
extern forth_state
extern is_number
extern parse_number
extern parse_string
extern word_not_found

global interpret
global ok

[section .text]

; Interprets the parse buffer, then jumps to the address in esi.
interpret:
	sub ebp, 4
	mov [ebp], esi
	mov byte [ok], 1
.loop:
	call parse_string
	test ecx, ecx
	jz .done

	call capitalize

	mov eax, [forth_state]
	mov eax, [.jump_table+4*eax]
	jmp eax
.jump_table:
	; 0 -> interpret mode
	dd .interpret_word
	; 1 -> compile mode
	dd .compile_word
	; 2, 3 -> comment mode
	dd .comment_word
	dd .comment_word

.interpret_word:
	call find
	test eax, eax
	jz .interpret_as_number

	mov esi, addr_of_loop
	lea eax, [eax+6+ecx]
	jmp eax

.interpret_as_number:
	call is_number
	test eax, eax
	jz .word_not_found

	call parse_number
	push eax
	jmp .loop

.compile_word:
	call find
	test eax, eax
	jz .compile_as_number

	mov dl, [eax+4]
	lea eax, [eax+6+ecx]

	test dl, 0x01
	jnz .compile_as_immediate

	mov edx, [forth_heap]
	mov [edx], eax
	add dword [forth_heap], 4

	jmp .loop

.compile_as_number:
	call is_number
	test eax, eax
	jz .word_not_found

	call parse_number
	mov edx, [forth_heap]
	mov dword [edx], forth_literal_impl.cfa
	mov [edx+4], eax
	add dword [forth_heap], 8
	jmp .loop

.compile_as_immediate:
	mov esi, addr_of_loop
	jmp eax

.comment_word:
	mov al, ')'
	repne scasb
	jne .loop
	and dword [forth_state], 1
	jmp .loop

.done:
	mov esi, [ebp]
	add ebp, 4
	jmp esi

.word_not_found:
	mov esi, .word_not_found_after_addr
	jmp word_not_found
.word_not_found_after:
	mov byte [ok], 0
	jmp .done
.word_not_found_after_addr: dd .word_not_found_after

[section .bss]

ok: resb 1

[section .rodata]

addr_of_loop: dd interpret.loop

; vi: cc=80 ft=nasm
