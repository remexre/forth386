bits 32

extern color
extern console_print_newline
extern console_print_number
extern console_print_string
extern console_read_line
extern console_refresh
extern cursor
extern enter
extern halt
extern heap_start
extern interpret
extern missing_name
extern ok
extern param_stack_top
extern parse_string
extern return_stack_top

global forth_base
global forth_dictionary
global forth_eat_flaming_death.cfa
global forth_exit.cfa
global forth_quit.cfa
global forth_state
global forth_to_in

%include "src/forth/common.inc"

[section .forth]

forth_abort: ; ( i * x -- )
	dd 0
	db 0x00, 5, "ABORT"
.cfa:
	mov esp, param_stack_top
	jmp forth_quit.cfa

forth_allot : ; ( n -- )
	dd forth_abort
	db 0x00, 5, "ALLOT"
.cfa:
	pop eax
	add [forth_heap], eax
	NEXT

forth_brack_left: ; ( -- )
	dd forth_allot
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

forth_char_fetch: ; ( c-addr -- char )
	dd forth_brack_right
	db 0x00, 2, "C@"
.cfa:
	FORTH_POP eax
	mov al, [eax]
	and eax, 0xff
	push eax
	NEXT

forth_char_store: ; ( char c-addr -- )
	dd forth_char_fetch
	db 0x00, 2, "C!"
.cfa:
	FORTH_POP ecx
	FORTH_POP eax
	mov [ecx], al
	NEXT

forth_colon: ; ( C: "name" -- colon-sys )
	dd forth_char_store
	db 0x00, 1, ":"
.cfa:
	JMP_ENTER
.pfa:
	dd forth_create.cfa
	dd forth_does_enter.cfa
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
	call parse_string
	and ecx, 0xff ; This is a bit of a hack...
	jz missing_name

	mov edx, [forth_heap]
	add [forth_heap], ecx
	add dword [forth_heap], 6

	mov eax, [forth_dictionary]
	mov [edx], eax
	mov [forth_dictionary], edx

	mov byte [edx+4], 0x02
	mov [edx+5], cl
	push esi
	mov esi, edi
	add edx, 6
	mov edi, edx
	rep movsb
	pop esi
	push edx
	NEXT

forth_decimal: ; ( -- )
	dd forth_create
	db 0x00, 7, "DECIMAL"
.cfa:
	mov dword [forth_base], 10
	NEXT

forth_does_enter: ; ( c-addr -- )
	dd forth_decimal
	db 0x00, 10, "DOES>ENTER"
.cfa:
	FORTH_POP eax
	mov byte [eax], 0xe9
	inc eax
	mov ecx, enter
	sub ecx, eax
	sub ecx, 4
	mov [eax], ecx
	add eax, 4
	mov [forth_heap], eax
	NEXT

forth_dot: ; ( n -- )
	dd forth_does_enter
	db 0x00, 1, "."
.cfa:
	FORTH_POP eax
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
	FORTH_POP eax
	NEXT

forth_dup: ; ( x -- x x )
	dd forth_drop
	db 0x00, 3, "DUP"
.cfa:
	FORTH_POP_CHK 1
	mov eax, [esp]
	push eax
	NEXT

forth_eat_flaming_death:
	dd forth_dup
	db 0x00, 17, "EAT-FLAMING-DEATH"
.cfa:
	mov ecx, 18
	mov edi, .pfa
	call console_print_string
	call console_print_newline
	mov byte [color], 0x4e
	jmp halt
.pfa:
	db "Dying in a fire..."

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
	FORTH_POP_CHK 1
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

forth_here: ; ( -- c-addr )
	dd forth_from_r
	db 0x00, 4, "HERE"
.cfa:
	mov eax, [forth_heap]
	push eax
	NEXT

forth_hex: ; ( -- )
	dd forth_here
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

forth_interpret: ; ( -- )
	dd forth_int3
	db 0x02, 9, "INTERPRET"
.cfa:
	jmp interpret

forth_minus: ; ( a b -- a-b )
	dd forth_interpret
	db 0x00, 1, "-"
.cfa:
	FORTH_POP ecx
	FORTH_POP eax
	sub eax, ecx
	push eax
	NEXT

forth_paren_left:
	dd forth_minus
	db 0x01, 1, "("
.cfa:
	or dword [forth_state], 0x02
	NEXT

forth_plus: ; ( a b -- a+b )
	dd forth_paren_left
	db 0x00, 1, "+"
.cfa:
	FORTH_POP ecx
	FORTH_POP eax
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
	call console_read_line
	mov eax, .enter
	jmp .enter
.print_ok:
	cmp byte [ok], 0
	je .skip_ok
	mov edx, 80
	mov ax, [cursor]
	div dl
	test ah, ah
	jz .skip_nl
	call console_print_newline
.skip_nl:
	mov ecx, 2
	mov edi, .ok
	call console_print_string
	call console_print_newline
.skip_ok:
	NEXT
.ok: db "ok"
.enter:
	JMP_ENTER
.pfa:
	dd forth_interpret.cfa
	dd forth_quit.print_ok
	dd forth_quit.cfa

forth_semicolon: ; ( -- )
	dd forth_quit
	db 0x01, 1, ";"
.cfa:
	JMP_ENTER
.pfa:
	dd forth_brack_left.cfa
	dd forth_unsmudge.cfa
	dd .align_heap
	dd forth_exit.cfa
.align_heap:
	mov edx, [forth_heap]
	test dl, 0x3
	jz .align_heap_done
	add edx, 0x04
	and dl, 0xfc
	mov [forth_heap], edx
.align_heap_done:
	NEXT

forth_state_word: ; ( -- a-addr )
	dd forth_semicolon
	db 0x00, 5, "STATE"
.cfa:
	push dword forth_state
	NEXT

forth_store: ; ( x a-addr -- )
	dd forth_state_word
	db 0x00, 1, "!"
.cfa:
	FORTH_POP ecx
	FORTH_POP eax
	mov [ecx], eax
	NEXT

forth_swap: ; ( x y -- y x )
	dd forth_store
	db 0x00, 4, "SWAP"
.cfa:
	FORTH_POP_CHK 2
	pop eax
	xchg eax, [esp]
	push eax
	NEXT

forth_to_r: ; ( x -- ) ( R: -- x )
	dd forth_swap
	db 0x00, 2, ">R"
.cfa:
	FORTH_POP eax
	sub ebp, 4
	mov [ebp], eax
	NEXT

forth_type: ; ( c-addr u -- )
	dd forth_to_r
	db 0x00, 4, "TYPE"
.cfa:
	FORTH_POP ecx
	FORTH_POP edi
	test ecx, ecx
	jz .cfa.end
	call console_print_string
.cfa.end:
	NEXT

forth_unsmudge: ; ( -- )
	dd forth_type
	db 0x00, 8, "UNSMUDGE"
.cfa:
	mov eax, [forth_dictionary]
	and byte [eax+4], 0xfd
	int3
	NEXT

forth_words: ; ( -- )
	dd forth_unsmudge
	db 0x00, 5, "WORDS"
.cfa:
	mov eax, forth_dictionary
	xor edx, edx
.loop:
	mov eax, [eax]
	test eax, eax
	jz .end
	test edx, edx
	jz .skip_space
	push eax
	push edx
	mov ecx, 1
	mov edi, .pfa
	call console_print_string
	pop edx
	pop eax
.skip_space:
	test byte [eax+4], 0x02
	jnz .loop
	xor ecx, ecx
	mov cl, [eax+5]
	lea edi, [eax+6]
	push eax
	push edx
	call console_print_string
	pop edx
	pop eax
	inc edx
	jmp .loop
.end:
	NEXT
.pfa:
	db ' '

forth_zero_equal: ; ( x -- flag )
	dd forth_words
	db 0x00, 2, "0="
.cfa:
	FORTH_POP eax
	test eax, eax
	setnz al
	and eax, 1
	dec eax
	push eax
	NEXT

[section .data]

forth_base: dd 10
forth_dictionary: dd forth_zero_equal
forth_heap: dd heap_start
forth_state: dd 0
forth_to_in: dd 0

; vi: cc=80 ft=nasm
