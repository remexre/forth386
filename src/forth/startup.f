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

: REBOOT $fe $64 OUTB ;

: set-color [ $123456 #16 + @ ] LITERAL c! ;

: hacker-mode $0a set-color ;
: hackar-mode $8a set-color ;
: reasonable-taste $0f set-color ;
reasonable-taste

\ : if s" [IF]" find compile, here .s ; immediate
\ : then here swap ! ;

\ : test dup 0= if s" zero!" type then . ;

: crr cr refresh ;
: loop-body 4 + dup . crr int3 recurse ;
: loop 0 loop-body ;

HEX
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
