bits 32

%macro debug 1
	push eax
	mov eax, %%str
extern debug_port_write_string
	call debug_port_write_string
	pop eax
	jmp %%after
%%str: db %1, 10, 0
%%after:
%endmacro

%macro debug_8bit 2
	push eax
	mov eax, %%str
extern debug_port_write_string
	call debug_port_write_string
	pop eax
	xchg al, %2
extern debug_port_write_byte
	call debug_port_write_byte
	xchg al, %2
	jmp %%after
%%str: db %1, ": 0x", 0
%%after:
%endmacro

; vi: cc=80 ft=nasm
