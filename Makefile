QEMUFLAGS += -d cpu_reset -d guest_errors -d int
QEMUFLAGS += -debugcon stdio
QEMUFLAGS += -m 64M

all: out/forth386.elf out/forth386.img
clean:
	rm -rf tmp out
run-qemu: out/forth386.img
	qemu-system-i386 -drive format=raw,file=out/forth386.img $(QEMUFLAGS)
.PHONY: all clean run-qemu

out/forth386.img: out/forth386.elf src/grub.cfg
	@grub-file --is-x86-multiboot2 out/forth386.elf
	@mkdir -p .isodir/boot/grub
	cp out/forth386.elf .isodir/boot/forth386.elf
	cp src/grub.cfg .isodir/boot/grub/grub.cfg
	@mkdir -p out
	grub-mkrescue -o $@ .isodir

out/forth386.elf: src/linker.ld tmp/forth.o tmp/multiboot2.o tmp/start.o
	@mkdir -p out
	ld -m elf_i386 -o $@ -T $^ -n -z max-page-size=0x1000

tmp/%.o: src/%.asm
	@mkdir -p tmp
	nasm -felf -o $@ $<
