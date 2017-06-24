BUILD := $(BUILD)/mbr

all: $(BUILD)/mbr

$(BUILD): 
	mkdir -p $(BUILD)
	
$(BUILD)/mbr: mbr.asm mbr.inc $(BUILD)
	nasm -f bin -O0 -o $(BUILD)/mbr mbr.asm

.PHONY: clean
clean:
	rm -rdf $(BUILD)
