: cls
  [ #80 #25 * ] literal
  times 0 i [ $123456 #8 + @ ] literal + c! loop
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
  $10 times space dup i + c@ hd-write-byte loop
  space $b3 emit space
  $10 times dup i + c@ emit loop
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
  $b3 emit 8 spaces $b3 emit
  $10 times space space dup i + hd-write-nybble loop
  space $b3 emit space
  $10 times dup i + hd-write-nybble loop
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

: print-cpu-vendor 0 0 cpuid drop ascii. swap ascii. ascii. ;

: grub-mb-head [ $123456 #4 + @ ] literal ;
: grub-tags-each ( xt -- ) \ The word should be ( tag-addr -- i*x )
  grub-mb-head dup dup @ + swap #8 +
  do
    i swap dup >r execute r>
    i #4 + @ 7 + 7 not and
  +loop drop ;

." Executing modules..." crr

:noname dup @ 3 = if
  ." Found module '" dup #16 + dup strlen 1- type ." '." crr
  dup #8 + @ swap #12 + @ over - interpret
  else drop endif ;
latest grub-tags-each

: streq ( addr len addr len -- bool )
  rot over =
  if true swap times .s ( todo ) loop rot rot 2drop
  else drop drop drop false
  endif ;

." Finished startup.f!" cr

reasonable-taste

\ Start the REPL.
ABORT

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
