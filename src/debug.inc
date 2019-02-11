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

; vi: cc=80 ft=nasm
