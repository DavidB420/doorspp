ASM_OUTPUT = ppboot.efi
C_OUTPUT = ppldr.sys

ASM_SOURCE = ppboot.asm
C_SOURCE = ppldr.c

CFLAGS ?= -m64
LDFLAGS ?= -Wl,--oformat=binary
ENTRYPOINT ?= -e main

all: $(ASM_OUTPUT) $(C_OUTPUT)

$(ASM_OUTPUT): $(ASM_SOURCE)
	fasm $< $@

$(C_OUTPUT): $(C_SOURCE)
	gcc $(CFLAGS) $(LDFLAGS) -c $< $(ENTRYPOINT) -o $@

clean:
	rm -f $(ASM_OUTPUT) $(C_OUTPUT)
