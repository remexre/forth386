bits 32

extern console_print_newline
extern console_print_number
extern console_print_string
extern console_refresh

[section .text]

; The main loop of the REPL.
global repl
repl:
	sti

.loop:
	hlt

	jmp .loop

; The handler for the Pause/Break key. When that key is pressed, this function
; is jumped to.
global brk
brk:
	inc dword [num]
	mov eax, [num]
	call console_print_number
	mov eax, brk_msg
	call console_print_string
	call console_print_newline
	call console_refresh
	jmp repl.loop

[section .data]

num: dd 0

global scancode_buf.bytes
global scancode_buf.cursor
scancode_buf:
.bytes: times 16 db 0
.cursor: db 0

[section .rodata]

brk_msg:
.len: dd .end - .str
.str: db "User pressed Break!"
.end:
