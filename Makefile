NASMFLAGS += -g
# QEMUFLAGS += -d cpu_reset -d guest_errors -d int
QEMUFLAGS += -debugcon stdio
QEMUFLAGS += -m 64M

UNITS += debug/debug_port
UNITS += forth
UNITS += io/ascii
UNITS += io/console_high
UNITS += io/console_low
UNITS += io/kbd
UNITS += io/ps2
UNITS += io/scancode_set_1
UNITS += ipb
UNITS += parse
UNITS += repl
UNITS += x86/gdt
UNITS += x86/idt
UNITS += x86/multiboot2
UNITS += x86/start

all: out/forth386.elf out/forth386.img
clean:
	rm -rf tmp out
debug: out/forth386.img out/forth386.sym
	gdb -x src/misc/script.gdb
disas: out/forth386-unstripped.elf
	objdump -M intel -d $< | less
help:
	@echo >&2 'Targets:'
	@echo >&2 '  all   - Builds the kernel and a boot image'
	@echo >&2 '  clean - Removes temporary and output files'
	@echo >&2 '  debug - Opens GDB, connected to QEMU, running the boot image'
	@echo >&2 '  disas - Disassembles the kernel'
	@echo >&2 '  run   - Runs the boot image in QEMU'
	@echo >&2 '  watch - Watches source files, recompiling on changes'
run: out/forth386.img
	qemu-system-i386 -drive format=raw,file=out/forth386.img $(QEMUFLAGS)
watch:
	watchexec -cre asm,cfg,inc,ld make
.PHONY: all clean debug disas help run watch

out/forth386.img: out/forth386.elf src/misc/grub.cfg
	@grub-file --is-x86-multiboot2 out/forth386.elf
	@mkdir -p .isodir/boot/grub
	cp out/forth386.elf .isodir/boot/forth386.elf
	cp src/misc/grub.cfg .isodir/boot/grub/grub.cfg
	@mkdir -p $(dir $@)
	grub-mkrescue -o $@ .isodir

out/forth386.elf out/forth386.sym: out/forth386-unstripped.elf
	@mkdir -p $(dir $@)
	cp out/forth386-unstripped.elf out/forth386.elf
	cp out/forth386-unstripped.elf out/forth386.sym
	strip --only-keep-debug out/forth386.sym
	strip --strip-debug out/forth386.elf

out/forth386-unstripped.elf: src/misc/linker.ld $(patsubst %,tmp/%.o,$(UNITS))
	@mkdir -p $(dir $@)
	ld -m elf_i386 -o $@ -T $^ -n -z max-page-size=0x1000

tmp/%.o: src/%.asm
	@mkdir -p $(dir $@)
	nasm -felf -o $@ $< $(NASMFLAGS)

tmp/x86/start.o: src/startup.f
