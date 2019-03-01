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
\ this is instead a version of [COMPILE] that appends to the execution
\ semantics of the word being compiled the same semantics that would occur if
\ COMPILE were to occur in an interpretive context. Treat the following as
\ equivalent:
\ CREATE FOO DOES>ENTER ' . TODO . ] EXIT [ UNSMUDGE
\ : FOO [COMPILE] . ;
CREATE [COMPILE] DOES>ENTER ] EXIT [ UNSMUDGE IMMEDIATE

: IF [ ' [IF] CFA ] LITERAL , HERE 0 , ; IMMEDIATE
: ELSE [ ' [ELSE] CFA ] LITERAL , HERE 0 , SWAP HERE SWAP ! ; IMMEDIATE
: ENDIF HERE SWAP ! ; IMMEDIATE

: [DO] ( limit first -- ) SWAP >R >R ;
: [+LOOP] ( n -- ) ( R: limit first -- )
  2R> 2 PICK + ROT DROP 2DUP 2>R = IF int3 ENDIF ;
: [LOOP] ( n -- ) ( R: limit first -- ) 1 [+LOOP] ;

: DO HERE [ ' [DO] CFA ] LITERAL , ; IMMEDIATE
: LOOP [ ' [LOOP] CFA ] LITERAL , , ; IMMEDIATE

\ : DISCARD ( XU ... X0 U ) 0 ?DO DROP LOOP ;

\ ." must by CREATEd manually, since S" is immediate.
CREATE ." DOES>ENTER COMPILE S" ]
  STATE @ IF [ ' TYPE CFA ] LITERAL , ELSE TYPE ENDIF EXIT
  [ UNSMUDGE IMMEDIATE

\ : CONSTANT CREATE , DOES> @ UNSMUDGE ;
\ : VARIABLE CREATE 1 CELLS ALLOT UNSMUDGE ;

: CHAR WORD DROP c@ ;
: BL $20 ; \ TODO $20 CONSTANT BL
: SPACE BL EMIT ;
\ TODO SPACES

\ TODO This is absurdly slow -- is there a dirty hack that'd make it more
\ reasonable? (On the other hand, writing to the screen is perhaps reasonable
\ as a bottleneck...)
: . ( X -- )
  [ $123456 #12 + @ ] literal w@
  #80 MOD IF SPACE ENDIF
  .NOSPACE ;

: CRR CR REFRESH ;
: HALT HLT RECURSE ;
: REBOOT ." Rebooting, please hold..." CRR $fe $64 OUTB HALT ;

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
