OUTPUT = ppboot.efi

SOURCE = ppboot.asm

all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	fasm $< $@

clean:
	rm -f $(OUTPUT)
