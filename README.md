forth386
========

A bare-metal Forth for i386 machines. Boots via Multiboot 2. Assumes a PS/2 keyboard (or PS/2 emulation).

Note that this does not precisely follow the ANS Forth standard.

Based on http://www.bradrodriguez.com/papers/moving1.htm -- read it before hacking.

Run `make help` to list available targets.

Building
--------

Requires binutils, GRUB, make, nasm, and xorriso.

Run `make` to build. The `out` directory will contain:

-	`forth386-unstripped.elf` -- An unstripped copy of the kernel.
-	`forth386.elf` -- A stripped copy of the kernel.
-	`forth386.img` -- A bootable disk image that boots Forth386.
-	`forth386.sym` -- The symbols that were stripped from the kernel.

License
-------

Licensed under either of

-	Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
-	MIT License: http://opensource.org/licenses/MIT

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
