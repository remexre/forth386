: ata-pio-buf $200000 ; \ TODO Use a CONSTANT

\ Waits for "400ns" for the drive, then reads status.
: ata-pio-400ns-read ( -- status-byte )
  0 5 times
    drop $1f7 inb
  loop ;

\ Waits for the device to be ready.
: ata-pio-wait-ready ( -- )
  ata-pio-400ns-read $8 and 0= if recurse endif ;

\ Reads a sector into &ata-pio-buf[512*i].
: ata-pio-read-sector ( i -- )
  #512 * ata-pio-buf +
  dup #512 + swap do $1f0 inw i w!
  #2 +loop ;

\ Sends a READ EXT for a given (48-bit) LBA.
: ata-pio-send-read-ext ( lba-high-dword lba-low-dword -- )
  \ Select the primary drive. TODO This should probably not hardcode this in...
  $40 $1f6 outb
  $08 $1f2 outb \ High byte of sector count.
  dup #24 rshift $1f3 outb \ Write byte 4
  swap dup       $1f4 outb \ Write byte 5
       #8 rshift $1f5 outb \ Write byte 6
  $00 $1f2 outb \ Low byte of sector count.
  dup            $1f3 outb \ Write byte 1
  dup  #8 rshift $1f4 outb \ Write byte 2
      #16 rshift $1f5 outb \ Write byte 3
  $24 $1f7 outb ; \ Send the "READ EXT" command.

\ Reads a megabyte off the disk starting at the given LBA.
: ata-pio-read ( lba-high-dword lba-low-dword -- )
  ata-pio-send-read-ext
  $800 times ata-pio-wait-ready i ata-pio-read-sector loop ;
0 0 ata-pio-read

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
