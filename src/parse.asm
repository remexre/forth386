bits 32

[section .text]

; Reads an integer or hex value from the string pointed to by edi, with the
; length in ecx. Returns the value in eax.
global read_int
read_int:
	int3
	jmp read_int

; vi: cc=80 ft=nasm
