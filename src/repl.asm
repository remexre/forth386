bits 32

%include "src/debug.inc"

extern console_print_char
extern console_print_newline
extern console_print_string
extern console_refresh
extern get_ascii

[section .text]

; The main loop of the REPL.
global repl
repl:
	sti

.loop:
	call get_ascii
	call console_print_char
	call console_refresh
	jmp .loop

; The handler for the Pause/Break key. When that key is pressed, this function
; is jumped to.
global brk
brk:
	int3
	jmp repl.loop

; vi: cc=80 ft=nasm
