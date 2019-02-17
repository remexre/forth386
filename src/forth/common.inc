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

%macro NEXT 0
	lodsd
	jmp eax
%endmacro

; TODO: Is this even what we want?
NEXT_LEN equ 3

; vi: cc=80 ft=nasm
