(
: cls
  [ $123456 #8 + @ #80 #25 * + ] literal
  [ $123456 #8 + @ ] literal
  do 0 i c! loop
  0 [ $123456 #12 + @ ] literal w!
  refresh ;
)

: cls-loop
  dup
  [ $123456 #8 + @ #80 #25 * + ] literal
  <> if dup 0 swap c! 1+ recurse endif ;
: cls
  [ $123456 #8 + @ ] literal cls-loop drop
  0 [ $123456 #12 + @ ] literal w! refresh ;

: set-color [ $123456 #16 + @ ] literal c! refresh ;

: hacker-mode $0a set-color ;
: hackar-mode $82 set-color ;
: reasonable-taste $0f set-color ;

: hexdump-write-nybble ( u -- ) $f and s" 0123456789abcdef" drop + c@ emit ;
: hexdump-write-byte ( u -- )
  dup $4 rshift
  hexdump-write-nybble
  hexdump-write-nybble ;
: hexdump-write-dword ( u -- )
  dup $18 rshift hexdump-write-byte
  dup $10 rshift hexdump-write-byte
  dup  $8 rshift hexdump-write-byte
                hexdump-write-byte ;
: hexdump-write-row ( addr -- )
  $b3 emit dup hexdump-write-dword $b3 emit
  \ This could benefit from a loop...
  space dup      c@ hexdump-write-byte
  space dup $1 + c@ hexdump-write-byte
  space dup $2 + c@ hexdump-write-byte
  space dup $3 + c@ hexdump-write-byte
  space dup $4 + c@ hexdump-write-byte
  space dup $5 + c@ hexdump-write-byte
  space dup $6 + c@ hexdump-write-byte
  space dup $7 + c@ hexdump-write-byte
  space dup $8 + c@ hexdump-write-byte
  space dup $9 + c@ hexdump-write-byte
  space dup $a + c@ hexdump-write-byte
  space dup $b + c@ hexdump-write-byte
  space dup $c + c@ hexdump-write-byte
  space dup $d + c@ hexdump-write-byte
  space dup $e + c@ hexdump-write-byte
  space dup $f + c@ hexdump-write-byte
  space $b3 emit space
  \ This could benefit from a loop...
  dup      c@ emit
  dup $1 + c@ emit
  dup $2 + c@ emit
  dup $3 + c@ emit
  dup $4 + c@ emit
  dup $5 + c@ emit
  dup $6 + c@ emit
  dup $7 + c@ emit
  dup $8 + c@ emit
  dup $9 + c@ emit
  dup $a + c@ emit
  dup $b + c@ emit
  dup $c + c@ emit
  dup $d + c@ emit
  dup $e + c@ emit
      $f + c@ emit
  space $b3 emit cr ;
: hexdump ( addr -- )
  \ BIG rip, it'd be nice to better syntax here...
  $da emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c2 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c2 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $bf emit cr
  \ And a loop here...
  $b3 emit space space space space space space space space $b3 emit
  space space dup      hexdump-write-nybble
  space space dup $1 + hexdump-write-nybble 
  space space dup $2 + hexdump-write-nybble
  space space dup $3 + hexdump-write-nybble
  space space dup $4 + hexdump-write-nybble
  space space dup $5 + hexdump-write-nybble
  space space dup $6 + hexdump-write-nybble
  space space dup $7 + hexdump-write-nybble
  space space dup $8 + hexdump-write-nybble
  space space dup $9 + hexdump-write-nybble
  space space dup $a + hexdump-write-nybble
  space space dup $b + hexdump-write-nybble
  space space dup $c + hexdump-write-nybble
  space space dup $d + hexdump-write-nybble
  space space dup $e + hexdump-write-nybble
  space space dup $f + hexdump-write-nybble

  space $b3 emit space
  dup      hexdump-write-nybble
  dup $1 + hexdump-write-nybble 
  dup $2 + hexdump-write-nybble
  dup $3 + hexdump-write-nybble
  dup $4 + hexdump-write-nybble
  dup $5 + hexdump-write-nybble
  dup $6 + hexdump-write-nybble
  dup $7 + hexdump-write-nybble
  dup $8 + hexdump-write-nybble
  dup $9 + hexdump-write-nybble
  dup $a + hexdump-write-nybble
  dup $b + hexdump-write-nybble
  dup $c + hexdump-write-nybble
  dup $d + hexdump-write-nybble
  dup $e + hexdump-write-nybble
  dup $f + hexdump-write-nybble
  space $b3 emit cr
  \ And another byte array here...
  $c3 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c5 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c5 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $b4 emit cr
  \ This could benefit from a loop...
  dup       hexdump-write-row
  dup $10 + hexdump-write-row
  dup $20 + hexdump-write-row
  dup $30 + hexdump-write-row
  dup $40 + hexdump-write-row
  dup $50 + hexdump-write-row
  dup $60 + hexdump-write-row
      $70 + hexdump-write-row
  \ More byte arrays being necessary...
  $c0 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c1 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c1 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $d9 emit crr ;

\ : DOES> [ ' [DOES>] CFA ] LITERAL , ; IMMEDIATE
\ : CONST CREATE , DOES> @ UNSMUDGE ;
\ ' DOES> hexdump

\ $123456 CONSTANT IPB
\ ." IPB-CHECK" IPB @ $00425049 2DUP = . . . ;

\ IPB 4 + @                 CONSTANT MB2-STRUCT
\ MB2-STRUCT MB2-STRUCT @ + CONSTANT MB2-STRUCT-END

\ : SEARCH-TAG ( tag-type addr -- addr )
  \ 2DUP @ = IF
    \ NIP
  \ ELSE
    \ DUP 4 + @ + RECURSE
  \ ENDIF
\ ;
\ : FIND-TAG ( tag-type -- addr )
  \ MB2-STRUCT 8 +
\ ;

\ Print the boot command line arguments.
\ 1 FIND-TAG 8 + @ DUP STRLEN TYPE

." Finished startup.f!" cr

reasonable-taste
HEX
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
