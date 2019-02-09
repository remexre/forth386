bits 32

extern console_print_number
extern console_print_space
extern console_refresh

[section .forthk]

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

next:
	lodsd
	jmp eax
next_len equ $ - next

%macro NEXT 0
	lodsd
	jmp eax
%endmacro

enter:
	; Push IP to the Return Stack
	xchg ebp, esp
	push esi
	xchg ebp, esp
	; Make IP point to the Parameter Field
	lea esi, [eax+next_len]
	NEXT

exit:
	; Pop the previously pushed IP from the Return Stack
	xchg ebp, esp
	pop esi
	xchg ebp, esp
	NEXT

docon:
	; Move the (only) word in the Parameter Field into eax
	mov eax, [eax+docon_len]
	; Push it to the Parameter Stack
	push eax
	NEXT
docon_len equ $ - docon

[section .forthl]

forth_dot: ; ( n -- )
.cfa:
	pop eax
	call console_print_number
	call console_refresh
	NEXT

forth_fetch: ; ( a-addr -- x )
.cfa:
	mov eax, [esp]
	mov eax, [eax]
	mov [esp], eax
	NEXT

forth_store: ; ( x a-addr -- )
.cfa:
	pop ecx
	pop eax
	mov [ecx], eax
	NEXT

; vi: cc=80 ft=nasm
