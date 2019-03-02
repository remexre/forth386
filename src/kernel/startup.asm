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

[section .text]

; Performs a cold start.
cold:
	mov ecx, forth_std_len
	mov edi, forth_std
	call set_parse_buffer
	mov esi, .std_done_addr
	jmp interpret

.std_done:
	mov al, [ok]
	test al, al
	jz panic

	mov ecx, startup_len
	mov edi, startup
	call set_parse_buffer
	mov esi, .startup_done_addr
	jmp interpret

.startup_done:
	mov al, [ok]
	test al, al
	jz panic

	mov edi, .str_startup_exited
	jmp halt
.str_startup_exited: db "src/forth/startup.f exited", 0

.startup_done_addr: dd .startup_done
.std_done_addr: dd .std_done

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
forth_std_len equ $-forth_std

startup:
incbin "src/forth/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
