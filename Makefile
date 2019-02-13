NASMFLAGS += -g
# QEMUFLAGS += -d cpu_reset -d guest_errors -d int
QEMUFLAGS += -debugcon stdio
QEMUFLAGS += -m 64M

UNITS  = ascii console_high console_low debug_port forth gdt kbd ipb idt
UNITS += multiboot2 ps2 repl scancode_set_1 start

all: out/forth386.elf out/forth386.img
clean:
	rm -rf tmp out
debug: out/forth386.img out/forth386.sym
	gdb -x src/script.gdb
disas: out/forth386-unstripped.elf
	objdump -M intel -d $< | less
run: out/forth386.img
	qemu-system-i386 -drive format=raw,file=out/forth386.img $(QEMUFLAGS)
watch:
	watchexec -cre asm,cfg,inc,ld make
.PHONY: all clean debug disas run watch

out/forth386.img: out/forth386.elf src/grub.cfg
	@grub-file --is-x86-multiboot2 out/forth386.elf
	@mkdir -p .isodir/boot/grub
	cp out/forth386.elf .isodir/boot/forth386.elf
	cp src/grub.cfg .isodir/boot/grub/grub.cfg
	@mkdir -p out
	grub-mkrescue -o $@ .isodir

out/forth386.elf out/forth386.sym: out/forth386-unstripped.elf
	@mkdir -p out
	cp out/forth386-unstripped.elf out/forth386.elf
	cp out/forth386-unstripped.elf out/forth386.sym
	strip --only-keep-debug out/forth386.sym
	strip --strip-debug out/forth386.elf

out/forth386-unstripped.elf: src/linker.ld $(patsubst %,tmp/%.o,$(UNITS))
	@mkdir -p out
	ld -m elf_i386 -o $@ -T $^ -n -z max-page-size=0x1000

tmp/%.o: src/%.asm
	@mkdir -p tmp
	nasm -felf -o $@ $< $(NASMFLAGS)
