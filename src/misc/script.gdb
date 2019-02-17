add-symbol-file out/forth386.sym 0
break start
break bp_handler
break ud_handler
break df_handler
break gp_handler
break pf_handler
target remote | qemu-system-i386 -gdb stdio -m 64M -drive format=raw,file=out/forth386.img
define l
	layout asm
	layout regs
	focus cmd
end
define nsi
	next
	stepi
end
continue

# vi: ft=gdb
