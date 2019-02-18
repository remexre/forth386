bits 32

extern interpret
extern panic
extern set_parse_buffer

global cold
global ctrl_alt_delete

[section .text]

; Performs a cold start.
cold:
	mov ecx, startup_len
	mov edi, startup
	call set_parse_buffer
	mov esi, .addr_of_panic
	jmp interpret
.addr_of_panic: dd panic

; The break handler.
brk:
	; TODO: This should probably be somewhat more elaborate.
	jmp cold

; The ctrl-alt-delete handler.
ctrl_alt_delete:
	cli
	pause
	in al, 0x64
	test al, 0x20
	jnz ctrl_alt_delete
	mov al, 0xfe
	out 0x64, al
	hlt
	jmp ctrl_alt_delete

[section .startup]

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
