bits 32

extern console_print_newline
extern console_print_string
extern console_read_line
extern console_refresh
extern halt
extern parse_string

[section .text]

; Performs a cold start.
global cold.cfa
cold:
.cfa:
	; push startup
	; push startup_len
	; call console_read_line
	; mov ecx, 4
	; mov edi, startup
	; call console_print_string
	; call console_refresh

	call console_read_line

.loop:
	call parse_string
	test ecx, ecx
	jz halt
.print:
	call console_print_string
	call console_print_newline

	jmp .loop

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
