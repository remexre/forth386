bits 32

extern enter
extern forth_state
extern param_stack_top
extern return_stack_top

[section .forth]

%include "src/forth/common.inc"

global forth_abort.cfa
forth_abort:
.cfa:
	mov esp, param_stack_top
	jmp enter
.pfa:
	dd forth_quit.cfa

global forth_cold.cfa
forth_cold:
.cfa:
	jmp enter
.pfa:
	dd forth_abort.cfa

global forth_interpret.cfa
forth_interpret:
.cfa:
	int3
	jmp $
.pfa:

forth_print_ok:
.cfa:
	push .ok
	push 3
	jmp enter
.pfa:
	int3
	jmp $
	NEXT

global forth_quit.cfa
forth_quit:
.cfa:
	mov ebp, return_stack_top
	mov dword [forth_state], 0
	jmp enter
.pfa:
	dd forth_accept.cfa
	dd forth_interpret.cfa
	dd forth_print_ok.cfa
	dd forth_quit.cfa

; vi: cc=80 ft=nasm
