bits 32

extern capitalize
extern find
extern halt
extern is_number
extern parse_string
extern parse_number
extern set_parse_buffer

extern console_print_string
extern console_print_newline
extern console_refresh

global cold.cfa

[section .text]

; Performs a cold start.
cold:
.cfa:
	mov ecx, startup_len
	mov edi, startup
	call set_parse_buffer

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

	mov esi, .addr_of_loop
	lea eax, [eax+6+ecx]
	jmp eax
.addr_of_loop: dd .loop

.done:
	mov ecx, startup_finished_len
	mov edi, strs.startup_finished
	call console_print_string
	jmp halt

.word_not_found:
	push ecx
	push edi
	mov ecx, word_not_found_len
	mov edi, strs.word_not_found
	call console_print_string
	pop edi
	pop ecx
	call console_print_string
	call console_print_newline
	call console_refresh
	jmp halt

[section .rodata]

strs:
.startup_finished: db "Startup script finished; it should've called ABORT..."
startup_finished_len equ $-.startup_finished
.word_not_found: db "Word not found: "
word_not_found_len equ $-.word_not_found

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
