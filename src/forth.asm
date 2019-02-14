bits 32

extern console_print_dec
extern console_print_hex
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

forth_decimal: ; ( -- )
.cfa:
	mov dword [forth_printer], console_print_dec
	NEXT

forth_dot: ; ( n -- )
.cfa:
	pop eax
	mov ecx, [forth_printer]
	call ecx
	call console_refresh
	NEXT

forth_drop: ; ( x -- )
.cfa:
	add esp, 4
	NEXT

forth_dup: ; ( x -- x x )
.cfa:
	mov eax, [esp]
	push eax
	NEXT

forth_fetch: ; ( a-addr -- x )
.cfa:
	mov eax, [esp]
	mov eax, [eax]
	mov [esp], eax
	NEXT

forth_from_r: ; ( -- x ) ( R: x -- )
.cfa:
	mov eax, [ebp]
	add ebp, 4
	push eax
	NEXT

forth_hex: ; ( -- )
.cfa:
	mov dword [forth_printer], console_print_hex
	NEXT

forth_plus: ; ( a b -- a+b )
.cfa:
	pop ecx
	pop eax
	add eax, ecx
	push eax
	NEXT

forth_store: ; ( x a-addr -- )
.cfa:
	pop ecx
	pop eax
	mov [ecx], eax
	NEXT

forth_swap: ; ( x y -- y x )
.cfa:
	pop eax
	xchg eax, [esp]
	push eax
	NEXT

forth_to_r: ; ( x -- ) ( R: -- x )
.cfa:
	pop eax
	sub ebp, 4
	mov [ebp], eax
	NEXT

[section .data]

forth_printer: dd console_print_dec

; vi: cc=80 ft=nasm
