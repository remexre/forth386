bits 32

extern forth_eat_flaming_death.cfa
extern interpret
extern set_parse_buffer

global cold

[section .text]

; Performs a cold start.
cold:
	mov ecx, startup_len
	mov edi, startup
	call set_parse_buffer
	mov esi, .addr_of_flaming_death
	jmp interpret
.addr_of_flaming_death: dd forth_eat_flaming_death.cfa

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
