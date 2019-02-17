bits 32

extern console_print_newline
extern console_print_number
extern console_print_string
extern console_refresh
extern halt
extern heap_start
extern param_stack_top
extern return_stack_top

global enter
global forth_abort.cfa
global forth_base
global forth_dictionary
global forth_state
global forth_to_in

[section .forth]

%include "src/forth/common.inc"

enter:
	dd forth_dup
	db 0x00, 5, "ENTER"
	; Push IP to the Return Stack
	xchg ebp, esp
	push esi
	xchg ebp, esp
	; Make IP point to the Parameter Field
	lea esi, [eax+NEXT_LEN]
	NEXT

forth_docolon:
.cfa:
	; TODO
	int3

docon:
	; Move the (only) word in the Parameter Field into eax
	mov eax, [eax+docon_len]
	; Push it to the Parameter Stack
	push eax
	NEXT
docon_len equ $ - docon

forth_abort: ; ( x* -- )
	dd 0
	db 0x00, 5, "ABORT"
.cfa:
	mov esp, param_stack_top
	jmp forth_quit.cfa

forth_brack_left: ; ( -- )
	dd forth_abort
	db 0x01, 1, "["
.cfa:
	mov dword [forth_state], 0
	NEXT

forth_brack_right: ; ( -- )
	dd forth_brack_left
	db 0x00, 1, "]"
.cfa:
	mov dword [forth_state], 1
	NEXT

forth_colon: ; ( C: "name" -- colon-sys )
	dd forth_brack_right
	db 0x00, 1, ":"
.cfa:
	jmp enter
.pfa:
	dd forth_create.cfa
	dd forth_docolon.cfa
	dd forth_brack_right.cfa
	dd forth_exit.cfa

forth_cr: ; ( -- a-addr )
	dd forth_colon
	db 0x00, 2, "CR"
.cfa:
	call console_print_newline
	NEXT

forth_create: ; ( -- a-addr )
	dd forth_cr
	db 0x00, 6, "CREATE"
.cfa:
	int3 ; TODO
	push dword 0xb8000
	NEXT

forth_decimal: ; ( -- )
	dd forth_create
	db 0x00, 7, "DECIMAL"
.cfa:
	mov dword [forth_base], 10
	NEXT

forth_dot: ; ( n -- )
	dd forth_decimal
	db 0x00, 1, "."
.cfa:
	pop eax
	call console_print_number
	NEXT

forth_dot_s: ; ( -- )
	dd forth_dot
	db 0x00, 2, ".S"
.cfa:
	mov ecx, 1
	mov edi, .pfa
	call console_print_string
	mov eax, param_stack_top
	sub eax, esp
	shr eax, 2
	call console_print_number
	mov ecx, 1
	mov edi, .pfa+1
	call console_print_string

	push esi
	mov esi, param_stack_top
.loop:
	sub esi, 4
	cmp esi, esp
	je .done

	mov ecx, 1
	mov edi, .pfa+2
	call console_print_string

	mov eax, [esi]
	call console_print_number

	jmp .loop

.done:
	pop esi
	call console_print_newline
	call console_refresh
	NEXT
.pfa:
	db "<> "

forth_drop: ; ( x -- )
	dd forth_dot_s
	db 0x00, 4, "DROP"
.cfa:
	add esp, 4
	NEXT

forth_dup: ; ( x -- x x )
	dd forth_drop
	db 0x00, 3, "DUP"
.cfa:
	mov eax, [esp]
	push eax
	NEXT

forth_exit: ; ( -- ) ( R: nest-sys -- )
	dd forth_dup
	db 0x00, 4, "EXIT"
.cfa:
	; Pop the previously pushed IP from the Return Stack
	xchg ebp, esp
	pop esi
	xchg ebp, esp
	NEXT

forth_fetch: ; ( a-addr -- x )
	dd forth_exit
	db 0x00, 1, "@"
.cfa:
	mov eax, [esp]
	mov eax, [eax]
	mov [esp], eax
	NEXT

forth_from_r: ; ( -- x ) ( R: x -- )
	dd forth_fetch
	db 0x00, 2, "R>"
.cfa:
	mov eax, [ebp]
	add ebp, 4
	push eax
	NEXT

forth_hex: ; ( -- )
	dd forth_from_r
	db 0x00, 3, "HEX"
.cfa:
	mov dword [forth_base], 16
	NEXT

forth_immediate: ; ( -- )
	dd forth_hex
	db 0x00, 9, "IMMEDIATE"
.cfa:
	mov eax, [forth_dictionary]
	or byte [eax+4], 0x01
	NEXT

forth_int3: ; ( c-addr u -- )
	dd forth_immediate
	db 0x00, 4, "INT3"
.cfa:
	int3
	NEXT

forth_interpret: ; ( c-addr u -- )
	dd forth_int3
	db 0x02, 9, "INTERPRET"
.cfa:
	jmp halt ; TODO

forth_minus: ; ( a b -- a-b )
	dd forth_interpret
	db 0x00, 1, "-"
.cfa:
	pop ecx
	pop eax
	sub eax, ecx
	push eax
	NEXT

forth_plus: ; ( a b -- a+b )
	dd forth_minus
	db 0x00, 1, "+"
.cfa:
	pop ecx
	pop eax
	add eax, ecx
	push eax
	NEXT

forth_refresh: ; ( -- )
	dd forth_plus
	db 0x00, 7, "REFRESH"
.cfa:
	call console_refresh
	NEXT

forth_quit: ; ( R: x* -- )
	dd forth_refresh
	db 0x00, 4, "QUIT"
.cfa:
	mov ebp, return_stack_top
	mov dword [forth_state], 0
.eat_flaming_death:
	int3
	cli
	hlt
	jmp .eat_flaming_death

forth_state_word: ; ( -- a-addr )
	dd forth_quit
	db 0x00, 5, "STATE"
.cfa:
	push dword forth_state
	NEXT

forth_store: ; ( x a-addr -- )
	dd forth_state_word
	db 0x00, 1, "!"
.cfa:
	pop ecx
	pop eax
	mov [ecx], eax
	NEXT

forth_swap: ; ( x y -- y x )
	dd forth_store
	db 0x00, 4, "SWAP"
.cfa:
	pop eax
	xchg eax, [esp]
	push eax
	NEXT

forth_to_r: ; ( x -- ) ( R: -- x )
	dd forth_swap
	db 0x00, 2, ">R"
.cfa:
	pop eax
	sub ebp, 4
	mov [ebp], eax
	NEXT

forth_type: ; ( c-addr u -- )
	dd forth_to_r
	db 0x00, 4, "TYPE"
.cfa:
	pop ecx
	pop edi
	test ecx, ecx
	jz .cfa.end
	call console_print_string
.cfa.end:
	NEXT

[section .data]

forth_base: dd 10
forth_dictionary: dd forth_type
forth_heap: dd heap_start
forth_state: dd 0
forth_to_in: dd 0

; vi: cc=80 ft=nasm
