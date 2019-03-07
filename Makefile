NASMFLAGS += -gdwarf
QEMUFLAGS += -accel kvm
# QEMUFLAGS += -d cpu_reset -d guest_errors -d int
QEMUFLAGS += -debugcon stdio
QEMUFLAGS += -m 64M

ASM_UNITS += debug/debug_port
ASM_UNITS += io/ascii
ASM_UNITS += io/console_low
ASM_UNITS += io/console_read
ASM_UNITS += io/console_write
ASM_UNITS += io/kbd
ASM_UNITS += io/ps2
ASM_UNITS += io/scancode_set_1
ASM_UNITS += ipb
ASM_UNITS += kernel/builtins
ASM_UNITS += kernel/interpret
ASM_UNITS += kernel/parse
ASM_UNITS += kernel/startup
ASM_UNITS += kernel/utils
ASM_UNITS += x86/gdt
ASM_UNITS += x86/idt
ASM_UNITS += x86/multiboot2
ASM_UNITS += x86/start

FORTH_UNITS += acpi
FORTH_UNITS += ata-pio
FORTH_UNITS += gpt
FORTH_UNITS += mbr

ASM_OBJS = $(patsubst %,tmp/%.o,$(ASM_UNITS))
FORTH_SRCS = $(patsubst %,src/forth/%.f,$(FORTH_UNITS))

all: out/forth386.elf out/forth386.img
clean:
	rm -rf tmp out
debug: out/forth386.img out/forth386.sym
	gdb -x src/misc/script.gdb
disas: out/forth386-unstripped.elf
	objdump -M intel -d $< | less
help:
	@echo >&2 'Targets:'
	@echo >&2 '  all     - Builds the kernel and a boot image'
	@echo >&2 '  clean   - Removes temporary and output files'
	@echo >&2 '  debug   - Opens GDB, connected to QEMU, running the boot image'
	@echo >&2 '  disas   - Disassembles the kernel'
	@echo >&2 '  install - Installs the kernel and module to DESTDIR'
	@echo >&2 '  run     - Runs the boot image in QEMU'
	@echo >&2 '  watch   - Watches source files, recompiling on changes'
install: out/forth386.elf $(FORTH_SRCS)
	@mkdir -p $(DESTDIR)/boot/mods
	cp $(FORTH_SRCS) $(DESTDIR)/boot/mods/
	cp out/forth386.elf $(DESTDIR)/boot/
run: out/forth386.img
	qemu-system-i386 -drive format=raw,file=out/forth386.img,if=ide,media=disk $(QEMUFLAGS)
watch:
	watchexec -cre asm,cfg,inc,ld make
.PHONY: all clean debug disas help install run watch

out/forth386.img: out/forth386.elf src/misc/grub.cfg $(FORTH_SRCS)
	@grub-file --is-x86-multiboot2 out/forth386.elf
	@mkdir -p tmp/isodir/boot/grub
	cp out/forth386.elf tmp/isodir/boot/forth386.elf
	cp src/misc/grub.cfg tmp/isodir/boot/grub/grub.cfg
	@mkdir -p tmp/isodir/boot/mods
	cp $(FORTH_SRCS) tmp/isodir/boot/mods
	@mkdir -p $(dir $@)
	grub-mkrescue -o $@ tmp/isodir

out/forth386.elf out/forth386.sym: out/forth386-unstripped.elf
	@mkdir -p $(dir $@)
	cp out/forth386-unstripped.elf out/forth386.elf
	cp out/forth386-unstripped.elf out/forth386.sym
	strip --only-keep-debug out/forth386.sym
	strip out/forth386.elf

out/forth386-unstripped.elf: src/misc/linker.ld $(ASM_OBJS)
	@mkdir -p $(dir $@)
	ld -m elf_i386 -o $@ -T $^ -n -z max-page-size=0x1000

tmp/%.o: src/%.asm
	@mkdir -p $(dir $@)
	nasm -felf -o $@ $< $(NASMFLAGS)

tmp/io/scancode_set_1.o: src/io/keycodes.inc
tmp/kernel/builtins.o: src/kernel/common.inc
tmp/kernel/startup.o: src/forth/std.f
tmp/kernel/startup.o: src/forth/startup.f
tmp/kernel/utils.o: src/kernel/common.inc
tmp/x86/idt.o: src/debug/debug.inc
