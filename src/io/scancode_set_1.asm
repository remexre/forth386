bits 32

%include "src/io/keycodes.inc"

invalid_scancode  equ 0x7f
more_input        equ 0xff

[section .text]

; A state machine for scan codes from Set 1 of a PS/2 keyboard. Takes a scan
; code in al, returns a key code in al (if possible), 0x7f if input was
; invalid, or 0xff if more input is required. Trashes eax, ebx, ecx.
global scancode_set_1
scancode_set_1:
	; We use a jump table to choose which state to enter.
	xor ecx, ecx
	mov cl, [state]
	mov ecx, [state_jumps+ecx*4]
	jmp ecx

	; This is the entry state, where a key is beginning to be recognized. We
	; use a table to determine which key to use, since keys are extremely dense
	; here.
.state0:
	and eax, 0xff
	mov cl, al
	mov ebx, state0_jumps
	xlatb
	cmp al, more_input
	je .state0_more_input
	ret
.state0_more_input:
	and ecx, 1
	inc cl
	mov [state], cl
	ret

	; This is the state after reading 0xe0.
.state1:
	jmp .todo

	; This is the state after reading 0xe1.
.state2:
	jmp .todo

.todo:
	mov byte [state], 0x00
	mov al, 0x7f
	ret

[section .bss]

state: resb 1
buf: resb 6

[section .rodata]

state_jumps:
	dd scancode_set_1.state0
	dd scancode_set_1.state1
	dd scancode_set_1.state2

state0_jumps:
	db invalid_scancode, key_esc_down,     key_1_down,       key_2_down
	db key_3_down,       key_4_down,       key_5_down,       key_6_down
	db key_7_down,       key_8_down,       key_9_down,       key_0_down
	db key_minus_down,   key_equals_down,  key_bkspc_down,   key_tab_down

	db key_q_down,       key_w_down,       key_e_down,       key_r_down
	db key_t_down,       key_y_down,       key_u_down,       key_i_down
	db key_o_down,       key_p_down,       key_l_brack_down, key_r_brack_down
	db key_enter_down,   key_l_ctrl_down,  key_a_down,       key_s_down

	db key_d_down,       key_f_down,       key_g_down,       key_h_down
	db key_j_down,       key_k_down,       key_l_down,       key_semicln_down
	db key_quote_down,   key_grave_down,   key_l_shift_down, key_bkslash_down
	db key_z_down,       key_x_down,       key_c_down,       key_v_down

	db key_b_down,       key_n_down,       key_m_down,       key_comma_down
	db key_period_down,  key_slash_down,   key_r_shift_down, invalid_scancode
	;                                                        ^ numpad * down
	db key_l_alt_down,   key_space_down,   key_capslk_down,  key_f1_down
	db key_f2_down,      key_f3_down,      key_f4_down,      key_f5_down

	db key_f6_down,      key_f7_down,      key_f8_down,      key_f9_down
	db key_f10_down,     invalid_scancode, key_scrlk_down,   invalid_scancode
	;                    ^ numlk down                        ^ numpad 7 down
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 8 down   ^ numpad 9 down   ^ numpad - down   ^ numpad 4 down
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 5 down   ^ numpad 6 down   ^ numpad + down   ^ numpad 1 down

	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 2 down   ^ numpad 3 down   ^ numpad 0 down   ^ numpad . down
	db invalid_scancode, invalid_scancode, invalid_scancode, key_f11_down
	db key_f12_down,     invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode

	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode

	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode

	db invalid_scancode, key_esc_up,       key_1_up,         key_2_up
	db key_3_up,         key_4_up,         key_5_up,         key_6_up
	db key_7_up,         key_8_up,         key_9_up,         key_0_up
	db key_minus_up,     key_equals_up,    key_bkspc_up,     key_tab_up

	db key_q_up,         key_w_up,         key_e_up,         key_r_up
	db key_t_up,         key_y_up,         key_u_up,         key_i_up
	db key_o_up,         key_p_up,         key_l_brack_up,   key_r_brack_up
	db key_enter_up,     key_l_ctrl_up,    key_a_up,         key_s_up

	db key_d_up,         key_f_up,         key_g_up,         key_h_up
	db key_j_up,         key_k_up,         key_l_up,         key_semicln_up
	db key_quote_up,     key_grave_up,     key_l_shift_up,   key_bkslash_up
	db key_z_up,         key_x_up,         key_c_up,         key_v_up

	db key_b_up,         key_n_up,         key_m_up,         key_comma_up
	db key_period_up,    key_slash_up,     key_r_shift_up,   invalid_scancode
	;                                                        ^ numpad * up
	db key_l_alt_up,     key_space_up,     key_capslk_up,    key_f1_up
	db key_f2_up,        key_f3_up,        key_f4_up,        key_f5_up

	db key_f6_up,        key_f7_up,        key_f8_up,        key_f9_up
	db key_f10_up,       invalid_scancode, key_scrlk_up,     invalid_scancode
	;                    ^ numlk up                          ^ numpad 7 up
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 8 up     ^ numpad 9 up     ^ numpad - up     ^ numpad 4 up
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 5 up     ^ numpad 6 up     ^ numpad + up     ^ numpad 1 up

	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	;  ^ numpad 2 up     ^ numpad 3 up     ^ numpad 0 up     ^ numpad . up
	db invalid_scancode, invalid_scancode, invalid_scancode, key_f11_up
	db key_f12_up,       invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode

	db more_input,       more_input,       invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode

	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
	db invalid_scancode, invalid_scancode, invalid_scancode, invalid_scancode
%if ($-state0_jumps) != 256
%error "Bad State0 jump table"
%endif

; vi: cc=80 ft=nasm
