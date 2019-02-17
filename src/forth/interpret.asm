bits 32

extern capitalize
extern console_print_newline
extern console_print_string
extern console_refresh
extern find
extern forth_exit.cfa
extern is_number
extern parse_number
extern parse_string
extern set_parse_buffer

global interpret
global ok

[section .text]

; Interprets the parse buffer, then jumps to the address in esi.
interpret:
	xchg ebp, esp
	push esi
	xchg ebp, esp
	mov byte [ok], 1
.loop:
	call parse_string
	test ecx, ecx
	jz .done

	call capitalize

	call is_number
	test eax, eax
	jz .find_word

	call parse_number
	push eax
	jmp .loop

.find_word:
	call find
	test eax, eax
	jz .word_not_found

	mov esi, addr_of_loop
	lea eax, [eax+6+ecx]
	jmp eax

.done:
	jmp forth_exit.cfa

.word_not_found:
	push ecx
	push edi
	mov ecx, word_not_found_len
	mov edi, word_not_found
	call console_print_string
	pop edi
	pop ecx
	call console_print_string
	call console_print_newline
	call console_refresh
	mov byte [ok], 0
	jmp .done

[section .bss]

ok: resb 1

[section .rodata]

addr_of_loop: dd interpret.loop

word_not_found: db "Word not found: "
word_not_found_len equ $-word_not_found

; vi: cc=80 ft=nasm
