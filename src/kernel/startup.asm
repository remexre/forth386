bits 32

extern forth_zero_equal
extern halt
extern heap_start
extern interpret
extern ok
extern panic
extern set_parse_buffer

global cold
global ctrl_alt_delete
global forth_std
global forth_startup

[section .text]

; Performs a cold start.
cold:
	mov ecx, forth_std_len
	mov edi, forth_std
	call set_parse_buffer
	mov esi, .std_done
	jmp interpret

.std_done:
	mov al, [ok]
	test al, al
	jz panic

	mov ecx, startup_len
	mov edi, forth_startup
	call set_parse_buffer
	mov esi, .startup_done
	jmp interpret

.startup_done:
	mov al, [ok]
	test al, al
	jz panic

	mov edi, .str_startup_exited
	jmp halt
.str_startup_exited: db "src/forth/startup.f exited", 0

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

forth_std:
incbin "src/forth/std.f"
db 0
forth_std_len equ $-forth_std

forth_startup:
incbin "src/forth/startup.f"
db 0
startup_len equ $-forth_startup

; vi: cc=80 ft=nasm
