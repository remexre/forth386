create ata-pio-buf 512 allot

\ Waits for "400ns" for the drive, then reads status.
: ata-pio-400ns-read ( -- status-byte ) 0 5 times drop $1f7 inb loop ;

\ Waits for the DRQ bit to be set.
: ata-pio-wait-drq-set ( -- ) ata-pio-400ns-read $8 and 0= if recurse endif ;

\ Waits for the RDY bit to be set.
: ata-pio-wait-rdy-set ( -- ) ata-pio-400ns-read $40 and 0= if recurse endif ;

\ Reads a sector into ata-pio-buf.
: ata-pio-read-sector ( -- )
  ata-pio-buf #512 + ata-pio-buf do i . $1f0 inw i w! #2 +loop ;

\ Sets the drive on the primary ATA bus.
\ TODO This should be configurable, to support multi-disk machines.
: ata-pio-select-drive ( -- ) $40 $1f6 outb ;

\ Sends a READ SECTORS EXT for a given (48-bit) LBA.
: ata-pio-send-read-sectors-ext ( lba-high-dword lba-low-dword -- )
  \ TODO Have a length field.
  $00 $1f2 outb \ High byte of sector count.
  dup #24 rshift $1f3 outb \ Write byte 4
  swap dup       $1f4 outb \ Write byte 5
       #8 rshift $1f5 outb \ Write byte 6
  $01 $1f2 outb \ Low byte of sector count.
  dup            $1f3 outb \ Write byte 1
  dup  #8 rshift $1f4 outb \ Write byte 2
      #16 rshift $1f5 outb \ Write byte 3
  $24 $1f7 outb ; \ Send the "READ SECTORS EXT" command.

\ Sends a WRITE SECTORS EXT for a given (48-bit) LBA and length in sectors.
: ata-pio-send-write-sectors-ext ( lba-high-dword lba-low-dword len -- )
  dup #8 rshift $1f2 outb \ High byte of sector count.
  over #24 rshift $1f3 outb \ Write byte 4.
  rot dup $1f4 outb \ Write byte 5.
  #8 rshift $1f5 outb \ Write byte 6.
  $1f2 outb \ Low byte of sector count.
  dup $1f3 outb \ Write byte 1.
  dup #8 rshift $1f4 outb \ Write byte 2.
  #16 rshift $1f5 outb \ Write byte 3.
  $34 $1f7 outb ; \ Send the "WRITE SECTORS EXT" command.

\ Empties ata-pio-buf.
: ata-pio-empty ( -- ) ata-pio-buf #512 zero ;

\ Requests that the disk cache be flushed.
: ata-pio-flush ( -- ) ata-pio-select-drive $e7 $1f7 outb ;

\ Reads a megabyte off the disk starting at the given LBA.
: ata-pio-read ( lba-high-dword lba-low-dword -- )
  ata-pio-select-drive ata-pio-send-read-sectors-ext ata-pio-read-sector ;

\ Writes some block to disk. Note that the length is in (512-byte) sectors!
: ata-pio-write-block ( addr len lba-high-dword lba-low-dword )
  ata-pio-select-drive 2 pick ata-pio-send-write-sectors-ext
  todo ;

\ Writes ata-pio-buf to disk.
: ata-pio-write-buf ( lba-high-dword lba-low-dword -- )
  2>r ata-pio-buf #2048 2r> ata-pio-write-block ;

\ vim: set cc=80 ft=forth ss=2 sw=2 ts=2 et :
