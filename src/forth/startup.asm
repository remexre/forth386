bits 32

extern interpret
extern set_parse_buffer

global cold

[section .text]

; Performs a cold start.
cold:
	mov ecx, startup_len
	mov edi, startup
	call set_parse_buffer
	jmp interpret

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
