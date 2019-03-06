; We choose to use:
;
;  - eax as W
;  - ebx unused
;  - ecx as X / unused
;  - edx as Y / unused
;  - esi as IP
;  - edi unused
;  - ebp as RSP
;  - esp as PSP
;
; Header is:
;
;     +-------------------------------+
;     |           NEXT WORD           |
;     +-------+-------+---------------+
;     | FLAGS |  LEN  | NAME         ...
;     +-------+-------+---------------+
;
; Flags are:
;
;     0 (LSB) -- 1 iff IMMEDIATE
;     1       -- 1 iff smudged
;
; all others are reserved.

%macro FORTH_POP 1
	FORTH_POP_CHK 1
	pop dword %1
%endmacro

%macro FORTH_POP_CHK 1
	extern ipb.param_stack_top
	extern error_stack_underflow
	mov eax, [ipb.param_stack_top]
	sub eax, 4*%1
	cmp esp, eax
	ja error_stack_underflow
%endmacro

%macro JMP_ENTER 0
	jmp enter
%endmacro

; TODO: This implies that the jmp to enter must be of the 0xe9 variety.
JMP_LEN equ 5

%macro NEXT 0
	lodsd
	jmp eax
%endmacro

; vi: cc=80 ft=nasm
