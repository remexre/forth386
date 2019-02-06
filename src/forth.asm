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

enter:
	; Push IP to the Return Stack
	xchg ebp, esp
	push esi
	xchg ebp, esp
	; Make IP point to the Parameter Field
	lea esi, [eax+next_len]
	; NEXT
	lodsd
	jmp eax

exit:
	; Pop the previously pushed IP from the Return Stack
	xchg ebp, esp
	pop esi
	xchg ebp, esp
	; NEXT
	lodsd
	jmp eax

docon:
	; Move the (only) word in the Parameter Field into eax
	mov eax, [eax+docon_len]
	; Push it to the Parameter Stack
	push eax
	; NEXT
	lodsd
	jmp eax
docon_len equ $ - docon

[section .forthl]

forth_fetch: ; ( a-addr -- x )
.cfa:
	mov eax, [esp]
	mov eax, [eax]
	mov [esp], eax
	; NEXT
	lodsd
	jmp eax

forth_store: ; ( x a-addr -- )
.cfa:
	pop ecx
	pop eax
	mov [ecx], eax
	; NEXT
	lodsd
	jmp eax
