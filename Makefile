ASM_OUTPUT = ppboot.efi
C_OUTPUT = ppldr.sys

ASM_SOURCE = ppboot.asm
C_SOURCE = ppldr.c

CFLAGSLDR ?= -nostdlib -ffreestanding -m64 -o
LDFLAGSLDR ?= -no-pie -Ttext 0x30000
ENTRYPOINT ?= -e main

all: $(ASM_OUTPUT) $(C_OUTPUT)

$(ASM_OUTPUT): $(ASM_SOURCE)
	fasm $< $@

$(C_OUTPUT): $(C_SOURCE)
	gcc $(CFLAGSLDR) $@ $< $(LDFLAGSLDR) $(ENTRYPOINT)

clean:
	rm -f $(ASM_OUTPUT) $(C_OUTPUT)
