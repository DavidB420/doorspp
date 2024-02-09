C_SOURCE = uefigop.c
C_OUTPUT = uefigop.o
CFLAGSKRNL ?= -nostdlib -ffreestanding -m64 -o
ENTRYPOINT ?= -e main

all: $(C_OUTPUT)


$(C_OUTPUT): $(C_SOURCE)
	gcc $(CFLAGSKRNL) $@ -c $< $(ENTRYPOINT)

clean:
	rm -f $(C_OUTPUT)
