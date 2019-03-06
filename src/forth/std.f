\ The parts of the standard library that are implemented in Forth themselves.

\ COMPILE must by CREATEd manually, since ' is an immediate word.
CREATE COMPILE DOES>ENTER ' ' CFA , ] CFA , EXIT [ IMMEDIATE

\ For Rule-Of-Cool, define function definition.
CREATE : DOES>ENTER ] CREATE SMUDGE DOES>ENTER COMPILE ] EXIT [
CREATE ; DOES>ENTER
  ' [LITERAL] CFA ,
  ' EXIT      CFA ,
  ' ,         CFA ,
  ' [         CFA ,
  ] UNSMUDGE 4 ALIGN-HEAP EXIT [ IMMEDIATE

\ Anonymous word definition and function definition.
: CREATE-NONAME
  HERE LATEST , 0 W, $e9 C,
  [ ' [DOES>DEFAULT] CFA ] LITERAL HERE 4 + - ,
  SET-DICTIONARY HERE ;
CREATE :NONAME DOES>ENTER ] CREATE-NONAME DOES>ENTER COMPILE ] EXIT [

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

\ Some control-flow words.
: NIP   ( X1 X2 -- X2          ) SWAP DROP      ;
: OVER  ( X1 X2 -- X1 X2 X1    ) >R DUP R> SWAP ;
: TUCK  ( X1 X2 -- X2 X1 X2    ) SWAP OVER      ;
: 2DROP ( X1 X2 --             ) DROP DROP      ;
: 2DUP  ( X1 X2 -- X1 X2 X1 X2 ) OVER OVER      ;
: 2R>   ( -- X1 X2 ) ( R: X1 X2 -- ) R> R> R> ROT >R SWAP     ;
: 2>R   ( X1 X2 -- ) ( R: -- X1 X2 ) R> ROT ROT SWAP >R >R >R ;

\ And some math words.
: */ ( a b c -- a*b/c ) */MOD NIP ;
: /   ( a b -- a/b ) /MOD NIP ;
: MOD ( a b -- a%b ) /MOD DROP ;
: +! ( x addr -- ) DUP @ ROT + SWAP ! ;

\ We keep track of the "if depth" to make BREAK sane to define. The if depth is
\ basically how many words on the stack at compile-time are used for IF blocks.
HERE 0 , : IF-DEPTH LITERAL ; \ TODO use a VARIABLE
: SAVE-IF-DEPTH ( -- u ) IF-DEPTH @ 0 IF-DEPTH ! ;
: RESTORE-IF-DEPTH ( u -- ) IF-DEPTH ! ;

\ Define IF, UNLESS (i.e. NOT IF), ELSE, and ENDIF.
: IF [COMPILE] [IF] HERE 0 , 1 IF-DEPTH +! ; IMMEDIATE
: UNLESS [COMPILE] NOT [COMPILE] [IF] HERE 0 , 1 IF-DEPTH +! ; IMMEDIATE
: ELSE [COMPILE] [ELSE] HERE 0 , SWAP HERE SWAP ! ; IMMEDIATE
: ENDIF HERE SWAP ! -1 IF-DEPTH +! ; IMMEDIATE

\ Define TRUE and FALSE.
: TRUE $ffffffff ; \ TODO Use a CONSTANT
: FALSE 0 ; \ TODO Use a CONSTANT

\ TODO Support BREAK
\ : BEGIN SAVE-IF-DEPTH HERE ; IMMEDIATE
\ : AGAIN [COMPILE] [LITERAL] , [COMPILE] UNSAFE-GOTO RESTORE-IF-DEPTH ; IMMEDIATE

\ The runtime implementation of DO blocks.
: [DO] ( limit first -- ) ( R: -- i limit )
  SWAP-STACKS R> R> ROT 4 + SWAP-STACKS ;
: [?DO] ( limit first -- ) ( R: -- i limit )
  2DUP =
  IF 2DROP R> @ >R
  ELSE [ ' [DO] CFA 5 + ] LITERAL UNSAFE-GOTO
  ENDIF ;
: [+LOOP] ( n -- ) ( R: i limit -- )
  SWAP-STACKS ROT ROT SWAP-STACKS
  R> R> ROT + 2DUP =
  IF 2DROP SWAP-STACKS 4 + SWAP-STACKS
  ELSE >R >R SWAP-STACKS ROT SWAP-STACKS R> @ 4 + >R
  ENDIF ;
: [BREAK] R> @ @ R> R> 2DROP UNSAFE-GOTO ;

\ The compile-time DO, ?DO (DO with a first==limit check), LOOP, and +LOOP
\ (LOOP with a variable increment) words.
: DO SAVE-IF-DEPTH [COMPILE] [DO] HERE 0 , ; IMMEDIATE
: ?DO SAVE-IF-DEPTH [COMPILE] [?DO] HERE 0 , ; IMMEDIATE
: LOOP
  [COMPILE] [LITERAL] 1 , [COMPILE] [+LOOP]
  DUP , HERE SWAP ! RESTORE-IF-DEPTH ; IMMEDIATE
: +LOOP [COMPILE] [+LOOP] DUP , HERE SWAP ! RESTORE-IF-DEPTH ; IMMEDIATE
: BREAK [COMPILE] [BREAK] IF-DEPTH @ PICK , ; IMMEDIATE

\ Loop index variables.
: I ( -- i ) ( R: i limit -- i limit )
  SWAP-STACKS 2 PICK >R SWAP-STACKS ;

: DISCARD ( XU ... X0 U ) 0 ?DO DROP LOOP ;

\ : CONSTANT CREATE , DOES> @ ;
\ : VARIABLE CREATE 1 CELLS ALLOT ;

: CHAR WORD DROP c@ ;
: BL $20 ; \ TODO $20 CONSTANT BL
: QUOTE $22 EMIT ;
: SPACE BL EMIT ;
: SPACES 0 ?DO SPACE LOOP ;

HERE 0 , : ASCII.BUF LITERAL ; \ TODO use a VARIABLE
: ASCII. ( X -- ) ASCII.BUF ! ASCII.BUF 4 TYPE ;
: . ( X -- )
  \ TODO This is slower than it should be -- is it worth it to do bit-fuckery
  \ to optimize the division, and use a conditional jump instead of an IF?
  [ $123456 #12 + @ ] LITERAL W@
  #80 MOD IF SPACE ENDIF
  .NOSPACE ;
: ." COMPILE S" STATE @ IF [COMPILE] TYPE ELSE TYPE ENDIF ; IMMEDIATE

: CRR CR REFRESH ;
: HALT HLT RECURSE ;
: REBOOT ." Rebooting, please hold..." CRR $fe $64 OUTB HALT ;

HEX

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
