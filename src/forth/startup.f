: NIP SWAP DROP ;
: OVER >R DUP R> SWAP ;
: 2DUP OVER OVER ;

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
  \ THEN
\ ;
\ : FIND-TAG ( tag-type -- addr )
  \ MB2-STRUCT 8 +
\ ;

\ Print the boot command line arguments.
\ 1 FIND-TAG 8 + @ DUP STRLEN TYPE

: CRR CR REFRESH ;
: SP $20 EMIT ;

: REBOOT $fe $64 OUTB ;

: IF [ S" [IF]" FIND ] LITERAL , HERE ; IMMEDIATE
: THEN int3 HERE SWAP ! ; IMMEDIATE

(
: clear
  [ $123456 #8 + @ #80 #25 * + ] literal
  [ $123456 #8 + @ ] literal
  do 0 i c! loop
  0 [ $123456 #12 + @ ] literal w!
  refresh ;
)
: set-color [ $123456 #16 + @ ] literal c! ;

: hacker-mode $0a set-color ;
: hackar-mode $8a set-color ;
: reasonable-taste $0f set-color ;
reasonable-taste

: test dup 0= int3 if s" zero!" type then . ;

HEX
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
