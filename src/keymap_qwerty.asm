db 0x00
down:
.esc:  db 0x1b
.n1:   db '1'
.n2:   db '2'
.n3:   db '3'
.n4:   db '4'
.n5:   db '5'
.n6:   db '6'
.n7:   db '7'
.n8:   db '8'
.n9:   db '9'
.n0:   db '0'
.dash: db '-'

; Padding
times (256-($-$$)) db 0x0a
