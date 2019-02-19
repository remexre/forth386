: NIP SWAP DROP ;
: OVER >R DUP R> SWAP ;
: 2DUP OVER OVER ;

: VARIABLE CREATE 0 , ;

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

: REBOOT $fe $64 OUTB ;

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

: cls-inner dup 0 swap c! 1+ ;
: cls-loop
  dup
  [ $123456 #8 + @ #80 #25 * + ] literal
  = if cls-inner recurse endif ;
: cls
  [ $123456 #8 + @ ] literal cls-loop
  [ $123456 #12 + @ ] 0 literal w! ;

: set-color [ $123456 #16 + @ ] literal c! ;

: hacker-mode $0a set-color ;
: hackar-mode $82 set-color ;
: reasonable-taste $0f set-color ;

reasonable-taste
HEX
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
