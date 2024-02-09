ASM_OUTPUT = ppboot.efi
C_OBJOUTPUT = ppkrnl.o
C_OBJINPUT = ppkrnl.o
C_OUTPUT = ppkrnl.sys

ASM_SOURCE = ppboot.asm
C_SOURCE = ppkrnl.c

CFLAGSKRNL ?= -nostdlib -ffreestanding -m64 -o
LDFLAGSKRNL ?= -no-pie -Ttext 0x30000
ENTRYPOINT ?= -e main

all: $(ASM_OUTPUT) $(C_OBJOUTPUT) $(C_OUTPUT)

videoDrivers:
	$(MAKE) -C drivers/video

$(ASM_OUTPUT): $(ASM_SOURCE)
	fasm $< $@

$(C_OBJOUTPUT): $(C_SOURCE) videoDrivers
	gcc $(CFLAGSKRNL) $@ -c $< $(LDFLAGSKRNL) $(ENTRYPOINT)

$(C_OUTPUT): $(C_OBJINPUT)
	ld $(LDFLAGSKRNL) -o $@ $< drivers/video/*.o $(LDFLAGSKRNL) $(ENTRYPOINT)

clean:
	rm -f $(ASM_OUTPUT) $(C_OUTPUT) *.o
	rm -f drivers/video/*.o
