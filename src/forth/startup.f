$123456 $3 TYPE CR REFRESH
$123456 @ $00425046 - $123456 SWAP .S TYPE CR REFRESH .S
1 2 3 .S
0 .S

\ : CRR CR REFRESH ;

\ : NIP SWAP DROP ;
\ : OVER >R DUP R> SWAP ;
\ : 2DUP OVER OVER ;

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

\ ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
