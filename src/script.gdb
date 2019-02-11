add-symbol-file out/forth386.sym 0
break start
target remote | qemu-system-i386 -gdb stdio -m 64M -drive format=raw,file=out/forth386.img
continue
