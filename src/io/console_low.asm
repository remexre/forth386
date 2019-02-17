bits 32

global color
global console
global console_init
global console_refresh
global cursor

[section .text]

; Initializes the console. Trashes eax, ecx, edx, esi, edi.
console_init:
	; Set the high scanline to 14.
	mov dx, 0x03d4
	mov al, 0x0a
	out dx, al
	inc dx
	in al, dx
	and al, 0xc0
	or al, 14
	out dx, al

	; Set the low scanline to 15.
	dec dx
	mov al, 0x0b
	out dx, al
	inc dx
	in al, dx
	and al, 0xe0
	or al, 15
	out dx, al

	jmp console_refresh ; Tail-call.

; Draws the console to the screen and updates the cursor. Trashes ebx, ecx,
; edx, edi.
console_refresh:
	push eax
	push esi

	; Draw the console.
	mov ecx, 80*25
	mov esi, console
	mov edi, 0xb8000
	mov bh, [color]
.loop:
	mov bl, [esi]
	mov [edi], bx
	inc esi
	add edi, 2
	loop .loop

	; Update the cursor.
	mov bx, [cursor]
	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	inc dx
	mov al, bl
	out dx, al

	dec dx
	mov al, 0x0e
	out dx, al
	inc dx
	mov al, bh
	out dx, al

	pop esi
	pop eax
	ret

[section .data]

console:
	db "Welcome to Forth386!"
	times (80*25 - ($ - console)) db 0x20

cursor: dw 80

color: db 0x70

; vi: cc=80 ft=nasm
