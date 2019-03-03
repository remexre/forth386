: cls
  [ #80 #25 * ] literal
  0 do 0 i [ $123456 #8 + @ ] literal + c! loop
  0 [ $123456 #12 + @ ] literal w! refresh ;

: set-color [ $123456 #16 + @ ] literal c! refresh ;

: hacker-mode $0a set-color ;
: hackar-mode $82 set-color ;
: reasonable-taste $0f set-color ;
: macos-user-or-summat $70 set-color ;

: hd-write-nybble ( u -- ) $f and s" 0123456789abcdef" drop + c@ emit ;
: hd-write-byte ( u -- )
  dup $4 rshift
  hd-write-nybble
  hd-write-nybble ;
: hd-write-dword ( u -- )
  dup $18 rshift hd-write-byte
  dup $10 rshift hd-write-byte
  dup  $8 rshift hd-write-byte
                 hd-write-byte ;
: hd-write-row ( addr -- )
  $b3 emit dup hd-write-dword $b3 emit
  $10 0 do space dup i + c@ hd-write-byte loop
  space $b3 emit space
  $10 0 do dup i + c@ emit loop
  drop
  space $b3 emit cr ;
: hd ( addr -- )
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
  $b3 emit space space space space space space space space $b3 emit
  $10 0 do space space dup i + hd-write-nybble loop
  space $b3 emit space
  $10 0 do dup i + hd-write-nybble loop
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
  $80 0 do dup i + hd-write-row $10 +loop
  drop
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
\ ' DOES> hd

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

: acpi 0 ; \ TODO A patchable CONSTANT might be saner...
: acpi-sum-area ( addr len -- u )
  >r >r 0 r> r> over + swap do i c@ + loop $ff and ;
: acpi-find-rsdp
  0
  $00100000 $000e0000 do
  i @ $20445352 = if
    i 4 + @ $20525450 = if
      drop i
      i 20 acpi-sum-area 0= unless ." RSDP failed checksum!" abort endif
      break
    endif
  endif
  $10 +loop
  dup 0= if ." Couldn't find RSDP!" abort endif ;
: acpi-rsdp [ acpi-find-rsdp ] literal ;
: acpi-rsdt [ acpi-rsdp #16 + @ ] literal ;
: acpi-find-table ( table -- addr | 0 ) begin ." foo!" crr again ;

." RSDP is at 0x" acpi-rsdp .nospace cr
." RSDT is at 0x" acpi-rsdt .nospace cr
." DSDT is at 0x" $54445344 acpi-find-table .nospace cr

\ Start the REPL.
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
