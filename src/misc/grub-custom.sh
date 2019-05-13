#!/bin/sh
exec tail -n +3 $0

menuentry "Forth386" {
	search --no-floppy --fs-uuid --set=root 7692-41DA
	multiboot2 /boot/forth386.elf
	module2 /boot/mods/acpi.f    acpi.f
	module2 /boot/mods/ata-pio.f ata-pio.f
	module2 /boot/mods/fat.f     fat.f
	module2 /boot/mods/gpt.f     gpt.f
	boot
}
