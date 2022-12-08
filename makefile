TOOLS_PREFIX = aarch64-linux-musl-
GCC = $(TOOLS_PREFIX)gcc -T link.ld -ffreestanding -nostdlib 
OBJCOPY = $(TOOLS_PREFIX)objcopy -O binary

elf:
	$(GCC) src/init.S -o build/test.elf

img: elf
	$(OBJCOPY) build/test.elf build/test.img
