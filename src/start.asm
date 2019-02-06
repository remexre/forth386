bits 32

section .text

; The entry point to the kernel.
extern start
start:
	std ; So lodsd increments esi.
	mov esp, stack
	mov word [0xb8000], 0x4f21

; Halts the CPU.
halt:
	cli
	hlt
	jmp halt

section .bss

stack: resb 1024 * 1024
