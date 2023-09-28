ASM_OUTPUT = ppboot.efi
C_OUTPUT = ppldr.sys

ASM_SOURCE = ppboot.asm
C_SOURCE = ppldr.c

CFLAGSKRNL ?= -nostdlib -ffreestanding -m64 -o
LDFLAGSKRNL ?= -no-pie -Ttext 0x30000
ENTRYPOINT ?= -e main

all: $(ASM_OUTPUT) $(C_OUTPUT)

$(ASM_OUTPUT): $(ASM_SOURCE)
	fasm $< $@

$(C_OUTPUT): $(C_SOURCE)
	gcc $(CFLAGSKRNL) $@ $< $(LDFLAGSKRNL) $(ENTRYPOINT)

clean:
	rm -f $(ASM_OUTPUT) $(C_OUTPUT)
