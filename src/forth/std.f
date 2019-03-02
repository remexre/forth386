\ The parts of the standard library that are implemented in Forth themselves.

: NIP   ( X1 X2 -- X2          ) SWAP DROP      ;
: OVER  ( X1 X2 -- X1 X2 X1    ) >R DUP R> SWAP ;
: TUCK  ( X1 X2 -- X2 X1 X2    ) SWAP OVER      ;
: 2DROP ( X1 X2 --             ) DROP DROP      ;
: 2DUP  ( X1 X2 -- X1 X2 X1 X2 ) OVER OVER      ;
: 2R>   ( -- X1 X2 ) ( R: X1 X2 -- ) R> R> SWAP ;
: 2>R   ( X1 X2 -- ) ( R: -- X1 X2 ) SWAP R> R> ;

: */ ( a b c -- a*b/c ) */MOD NIP ;
: /   ( a b -- a/b ) /MOD NIP ;
: MOD ( a b -- a%b ) /MOD DROP ;

\ COMPILE must by CREATEd manually, since ' is an immediate word.
CREATE COMPILE DOES>ENTER ' ' CFA , ] CFA , EXIT [ UNSMUDGE IMMEDIATE

\ Note that this is not at all related to the [COMPILE] in the Forth standard;
\ this is instead a version of COMPILE that appends to the execution semantics
\ of the word being defined the same semantics that would occur if COMPILE were
\ to occur in an interpretive context. Treat the following as equivalent:
\ : FOO [ ' BAR CFA ] LITERAL , ;
\ : FOO [COMPILE] BAR ;
: [COMPILE]
  [ ' [LITERAL] CFA ] LITERAL ,
  COMPILE ' CFA ,
  [ ' , CFA ] LITERAL ,
  ; IMMEDIATE

: IF [COMPILE] [IF] HERE 0 , ; IMMEDIATE
: ELSE [COMPILE] [ELSE] HERE 0 , SWAP HERE SWAP ! ; IMMEDIATE
: ENDIF HERE SWAP ! ; IMMEDIATE

: TRUE $ffffffff ; \ TODO Use a CONSTANT
: FALSE 0 ; \ TODO Use a CONSTANT

: [DO] ( limit first -- ) ( R: -- i limit )
  SWAP-STACKS R> R> ROT 4 + SWAP-STACKS ;
: [?DO] ( limit first -- ) ( R: -- i limit )
  SWAP-STACKS R> R> 2DUP = >R ROT SWAP-STACKS R>
  SWAP NOT IF 4 + ELSE @ ENDIF >R
  R> DUP >R .NOSPACE REFRESH INT3 ;
: [+LOOP] ( n -- ) ( R: i limit -- )
  SWAP-STACKS ROT ROT SWAP-STACKS
  R> R> ROT + 2DUP =
  IF 2DROP SWAP-STACKS 4 + SWAP-STACKS
  ELSE >R >R SWAP-STACKS ROT SWAP-STACKS R> @ 4 + >R
  ENDIF ;
: I ( -- i ) ( R: i limit -- i limit )
  SWAP-STACKS 2 PICK >R SWAP-STACKS ;

: DO [COMPILE] [DO] HERE 0 , ; IMMEDIATE
: ?DO [COMPILE] [?DO] HERE 0 , ; IMMEDIATE
: LOOP [COMPILE] [LITERAL] 1 , [COMPILE] [+LOOP] DUP , HERE SWAP ! ; IMMEDIATE
: +LOOP [COMPILE] [+LOOP] DUP , HERE SWAP ! ; IMMEDIATE

\ : DISCARD ( XU ... X0 U ) 0 ?DO DROP LOOP ;

\ : CONSTANT CREATE , DOES> @ UNSMUDGE ;
\ : VARIABLE CREATE 1 CELLS ALLOT UNSMUDGE ;

: CHAR WORD DROP c@ ;
: BL $20 ; \ TODO $20 CONSTANT BL
: SPACE BL EMIT ;
: SPACES 0 ?DO SPACE LOOP ;

: . ( X -- )
  \ TODO This is slower than it should be -- is it worth it to do bit-fuckery
  \ to optimize the division, and use a conditional jump instead of an IF?
  [ $123456 #12 + @ ] literal w@
  #80 MOD IF SPACE ENDIF
  .NOSPACE ;
: ." COMPILE S" STATE @ IF [COMPILE] TYPE ELSE TYPE ENDIF ; IMMEDIATE

: CRR CR REFRESH ;
: HALT HLT RECURSE ;
: REBOOT ." Rebooting, please hold..." CRR $fe $64 OUTB HALT ;

HEX

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
