; Keycodes are roughly based on the keyboard layout of the T60 Thinkpad, since
; it's got pretty much every key on one keyboard, and there's one sitting next
; to me as I'm typing this.
;
; The layout is generally:
;
; Bit 7 (MSB): 0 if key down, 1 if key up
; Bits 6-4:    Row of the keyboard, 0 is bottom-most
; Bits 3-0:    Column of the keyboard, 0 is left-most

%macro define_keycode 3
%if %2 > 7
%error "arg 2 to define_keycode out of bounds"
%endif

%if %3 > 15
%error "arg 3 to define_keycode out of bounds"
%endif

key_%[%1]_down equ             (%2 << 4) | %3
key_%[%1]_up   equ 10000000b | (%2 << 4) | %3
%endmacro

; Fn key (doesn't exist)
define_keycode l_ctrl,  0,  1
define_keycode l_super, 0,  2
define_keycode l_alt,   0,  3
define_keycode space,   0,  4
define_keycode r_alt,   0,  5
define_keycode menu,    0,  6
define_keycode r_ctrl,  0,  7
; TODO: Weird left thing
define_keycode up,      0,  9
; TODO: Weird right thing
define_keycode left,    0, 11
define_keycode down,    0, 12
define_keycode right,   0, 13

define_keycode l_shift, 1,  0
define_keycode z,       1,  1
define_keycode x,       1,  2
define_keycode c,       1,  3
define_keycode v,       1,  4
define_keycode b,       1,  5
define_keycode n,       1,  6
define_keycode m,       1,  7
define_keycode comma,   1,  8
define_keycode period,  1,  9
define_keycode slash,   1, 10
define_keycode r_shift, 1, 11

define_keycode capslk,  2,  0
define_keycode a,       2,  1
define_keycode s,       2,  2
define_keycode d,       2,  3
define_keycode f,       2,  4
define_keycode g,       2,  5
define_keycode h,       2,  6
define_keycode j,       2,  7
define_keycode k,       2,  8
define_keycode l,       2,  9
define_keycode semicln, 2, 10
define_keycode quote,   2, 11
define_keycode enter,   2, 12

define_keycode tab,     3,  0
define_keycode q,       3,  1
define_keycode w,       3,  2
define_keycode e,       3,  3
define_keycode r,       3,  4
define_keycode t,       3,  5
define_keycode y,       3,  6
define_keycode u,       3,  7
define_keycode i,       3,  8
define_keycode o,       3,  9
define_keycode p,       3, 10
define_keycode l_brack, 3, 11
define_keycode r_brack, 3, 12
define_keycode bkslash, 3, 13

define_keycode grave,   4,  0
define_keycode 1,       4,  1
define_keycode 2,       4,  2
define_keycode 3,       4,  3
define_keycode 4,       4,  4
define_keycode 5,       4,  5
define_keycode 6,       4,  6
define_keycode 7,       4,  7
define_keycode 8,       4,  8
define_keycode 9,       4,  9
define_keycode 0,       4, 10
define_keycode minus,   4, 11
define_keycode equals,  4, 12
define_keycode bkspc,   4, 13

define_keycode f1,      5,  0
define_keycode f2,      5,  1
define_keycode f3,      5,  2
define_keycode f4,      5,  3
define_keycode f5,      5,  4
define_keycode f6,      5,  5
define_keycode f7,      5,  6
define_keycode f8,      5,  7
define_keycode f9,      5,  8
define_keycode f10,     5,  9
define_keycode f11,     5, 10
define_keycode f12,     5, 11
define_keycode delete,  5, 12
define_keycode end,     5, 13
define_keycode pg_down, 5, 14

define_keycode esc,     6,  0
define_keycode prtsc,   6,  1
define_keycode scrlk,   6,  2
define_keycode insert,  6,  4
define_keycode home,    6,  5
define_keycode pg_up,   6,  6

key_pause equ 0xe3

; vi: cc=80 ft=nasm
