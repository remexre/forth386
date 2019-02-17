bits 32

extern halt
extern parse_string
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
.print:
	call console_print_string
	call console_print_newline
	call console_refresh
	jmp .loop

.done
	jmp halt

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
