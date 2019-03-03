: acpi false ; \ This gets patched later on if loading ACPI was a success.
: acpi-sum-area ( addr len -- u )
  >r >r 0 r> r> over + swap do i c@ + loop $ff and ;
: acpi-find-rsdp
  0
  $00100000 $000e0000 do
  i @ $20445352 = if
    i 4 + @ $20525450 = if
      drop i
      i 20 acpi-sum-area 0= unless ." Warning: RSDP failed checksum!" endif
      break
    endif
  endif
  $10 +loop
  dup 0= if ." Couldn't find RSDP!" abort endif ;
: acpi-rsdp [ acpi-find-rsdp ] literal ;
' true cfa ' acpi #15 + ! \ Patch the acpi word to return true.

: acpi-rsdt [ acpi-rsdp #16 + @ ] literal ;
: acpi-table-length ( addr -- u ) 4 + @ ;
: acpi-find-table ( table -- addr | 0 )
  0
  acpi-rsdt acpi-table-length acpi-rsdt +
  acpi-rsdt #36 +
  do i @ dup @ 3 pick = if swap drop break endif drop 4 +loop swap drop ;
: acpi-list-tables
  acpi-rsdt acpi-table-length acpi-rsdt +
  acpi-rsdt #36 +
  do i @ dup @ ascii. space ." is at 0x" .nospace cr 4 +loop ;

." RSDP is at 0x" acpi-rsdp .nospace cr
." RSDT is at 0x" acpi-rsdt .nospace cr
acpi-list-tables

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
