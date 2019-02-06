forth386
========

A Forth for i386 machines. Boots via Multiboot 2. Assumes a PS/2 keyboard.

Note that this does not precisely follow the ANS Forth standard.

Based on http://www.bradrodriguez.com/papers/moving1.htm -- read it before hacking.

Code Organization
-----------------

`src/console.asm` is a simple console driver used to implement the REPL.

`src/forth.asm` is the actual Forth implementation.

`src/grub.cfg` and `src/multiboot2.asm` are used to boot Forth386.

`src/linker.ld` is the linker script used to produce an ELF executable.

`src/start.asm` is the entry point from the bootloader.
