bits 32

[section .text]

%define pic1_cmd  0x20
%define pic1_data 0x21
%define pic2_cmd  0xa0
%define pic2_data 0xa1

%macro write 2
	mov al, %2
	mov dx, %1
	out dx, al
%endmacro

; Remaps the PIC and sets up the IDT. Trashes eax, edx.
global idt_init
idt_init:
	; Initialize the first PIC.
	write pic1_cmd,  0x11 ; Initializing, expect 3 more "init words" on the
	                      ; data port.
	write pic1_data, 0x20 ; Vector Offset
	write pic1_data, 0x04 ; Master
	write pic1_data, 0x01 ; 8086 Mode
	write pic1_data, 0xff ; Disable all IRQs

	; Initialize the second PIC.
	write pic2_cmd,  0x11 ; Initializing, expect 3 more "init words" on the
	                      ; data port.
	write pic2_data, 0x28 ; Vector Offset
	write pic2_data, 0x02 ; Slave
	write pic2_data, 0x01 ; 8086 Mode
	write pic2_data, 0xff ; Disable all IRQs

	; Set up the IDT.
	lidt [idtr]
	ret

; Sets an IDT entry. Expects the interrupt number in eax, and the handler
; address in ecx. Trashes ecx.
global idt_set
idt_set:
	mov word [idt  +eax*8], cx
	mov word [idt+2+eax*8], 0x0008
	mov word [idt+4+eax*8], 0x8e00
	shr ecx, 16
	mov word [idt+6+eax*8], cx
	ret

[section .data]

idtr:
.size:   dw idt.end - idt - 1
.offset: dd idt

%macro idt_entry 3 ; offset, selector, type and attrs
	dw (%1 & 0xffff)
	dw %2
	db 0
	db %3
	dw (%1 >> 16)
%endmacro

global idt
idt: times 48 dq 0
.end:

; vi: cc=80 ft=nasm
