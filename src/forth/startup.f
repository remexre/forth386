: NIP SWAP DROP ;
: OVER >R DUP R> SWAP ;
: 2DUP OVER OVER ;

\ : CONSTANT CREATE #68 c, , #ac c, #ff c, #e0 c, UNSMUDGE ;
\ : VARIABLE CREATE 1 CELLS ALLOT ;

\ : TEST 1 2 + . ;
\ : HELLO-WORLD ." Hello, world!" ;

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

: CRR CR REFRESH ;
: SP $20 EMIT ;

: HALT HLT RECURSE ;
: REBOOT $fe $64 OUTB s" Rebooting, please hold..." TYPE CRR HALT ;

: IF [ S" [IF]" FIND #10 + ] LITERAL , HERE 0 , ; IMMEDIATE
: ENDIF HERE SWAP ! ; IMMEDIATE

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
  = if dup 0 swap c! 1+ recurse endif ;
: cls
  [ $123456 #8 + @ ] literal cls-loop drop
  [ $123456 #12 + @ ] 0 literal w! ;

: set-color [ $123456 #16 + @ ] literal c! ;

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
  sp dup      c@ hexdump-write-byte
  sp dup $1 + c@ hexdump-write-byte
  sp dup $2 + c@ hexdump-write-byte
  sp dup $3 + c@ hexdump-write-byte
  sp dup $4 + c@ hexdump-write-byte
  sp dup $5 + c@ hexdump-write-byte
  sp dup $6 + c@ hexdump-write-byte
  sp dup $7 + c@ hexdump-write-byte
  sp dup $8 + c@ hexdump-write-byte
  sp dup $9 + c@ hexdump-write-byte
  sp dup $a + c@ hexdump-write-byte
  sp dup $b + c@ hexdump-write-byte
  sp dup $c + c@ hexdump-write-byte
  sp dup $d + c@ hexdump-write-byte
  sp dup $e + c@ hexdump-write-byte
  sp dup $f + c@ hexdump-write-byte
  sp $b3 emit sp
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
  sp $b3 emit cr ;
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
  \ This could benefit from a loop...
  dup       hexdump-write-row
  dup $10 + hexdump-write-row
  dup $20 + hexdump-write-row
  dup $30 + hexdump-write-row
  dup $40 + hexdump-write-row
  dup $50 + hexdump-write-row
  dup $60 + hexdump-write-row
      $70 + hexdump-write-row
  \ big rip again
  $c0 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c1 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c1 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit
  $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $c4 emit $d9 emit cr ;

HEX

: DOES> [ S" [DOES>]" FIND #13 + ] LITERAL , ;
1 . SP HERE . CR
: CONST CREATE , DOES> @ ;
2 . SP HERE . CR
123 CONST X
3 . SP HERE . CR

reasonable-taste
HEX
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
