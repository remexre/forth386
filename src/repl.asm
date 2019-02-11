bits 32

%include "src/debug.inc"

extern console_print_char
extern console_print_newline
extern console_print_number
extern console_print_string
extern console_refresh
extern get_keycode

[section .text]

strs.start_repl: db "Start of REPL", 10, 0

; The main loop of the REPL.
global repl
repl:
	mov eax, strs.start_repl
extern debug_port_write_string
	call debug_port_write_string

	sti

.loop:
	debug "[repl] starting loop"
	call get_keycode
	debug "[repl] got char"
	call console_print_char
	debug "[repl] about to refresh"
	call console_refresh
	jmp .loop

; The handler for the Pause/Break key. When that key is pressed, this function
; is jumped to.
global brk
brk:
	mov eax, brk_msg
	call console_print_string
	call console_print_newline
	call console_refresh
	jmp repl.loop

[section .rodata]

brk_msg:
.len: dd .end - .str
.str: db "User pressed Break!"
.end:

; vi: cc=80 ft=nasm
