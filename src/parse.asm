bits 32

[section .text]

; Reads an integer or hex value from the currently parsed string. Returns the
; value in eax, and 0 in ecx on success. On failure, edi points to an error
; message, and ecx is the length of the message.
global read_int
read_int:
	int3
	jmp read_int

; Reads a token from the currently parsed string.
token:

[section .data]

; The length and location of the string being parsed.
global parsed_string.len
global parsed_string.ptr
parsed_string:
.len: dd startup_len
.ptr: dd startup

[section .startup]

startup:
incbin "src/startup.f"
startup_len equ $-startup

; vi: cc=80 ft=nasm
