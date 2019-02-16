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

%macro NEXT 0
	lodsd
	jmp eax
%endmacro

; TODO: Is this even what we want?
NEXT_LEN equ 3

; vi: cc=80 ft=nasm
