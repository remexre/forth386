bits 32

extern forth_error_handler
extern halt

global idt
global idt_init
global idt_set

%include "src/debug/debug.inc"

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

	; Set a few exception handlers.
	mov eax, 0 ; Divide-By-Zero
	mov ecx, de_handler
	call idt_set
	mov eax, 2 ; Non-Maskable Interrupt
	mov ecx, nmi_handler
	call idt_set
	mov eax, 3 ; Breakpoint
	mov ecx, bp_handler
	call idt_set
	mov eax, 6 ; Invalid Opcode
	mov ecx, ud_handler
	call idt_set
	mov eax, 8 ; Double Fault
	mov ecx, df_handler
	call idt_set
	mov eax, 13 ; General Protection Fault
	mov ecx, gp_handler
	call idt_set
	mov eax, 14 ; Page Fault
	mov ecx, pf_handler
	call idt_set

	; Set up the IDT.
	lidt [idtr]
	ret

; Sets an IDT entry. Expects the interrupt number in eax, and the handler
; address in ecx. Trashes ecx.
idt_set:
	mov word [idt  +eax*8], cx
	mov word [idt+2+eax*8], 0x0008
	mov word [idt+4+eax*8], 0x8e00
	shr ecx, 16
	mov word [idt+6+eax*8], cx
	ret

; The Divide-By-Zero handler.
de_handler:
	add esp, 8
	xor eax, eax
	mov [esp], eax
	mov eax, [forth_error_handler]
	jmp eax

; The Non-Maskable Interrupt handler.
nmi_handler:
	debug "NMI!"
	iret

; The Breakpoint handler.
bp_handler:
	debug "Breakpoint!"
	iret

; The Invalid Opcode handler.
ud_handler:
	debug "Invalid Opcode!"
	mov edi, .str
	jmp halt
.str: db "Invalid Opcode", 0

; The Double Fault handler.
df_handler:
	debug "Double Fault!"
	mov edi, .str
	jmp halt
.str: db "Double Fault", 0

; The General Protection Fault handler.
gp_handler:
	debug "General Protection Fault!"
	mov edi, .str
	jmp halt
.str: db "General Protection Fault", 0

; The Page Fault handler.
pf_handler:
	debug "Page Fault!"
	mov edi, .str
	jmp halt
.str: db "Page Fault", 0

[section .data]

idtr:
.size:   dw idt.end - idt - 1
.offset: dd idt

[section .bss]

idt: resq 48
.end:

; vi: cc=80 ft=nasm
