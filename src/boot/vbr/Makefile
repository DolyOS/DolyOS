BUILD := $(BUILD)/vbr

all: $(BUILD)/vbr

$(BUILD): 
	mkdir -p $(BUILD)
	
$(BUILD)/vbr: vbr.asm vbr.inc $(BUILD)
	nasm -f bin -O0 -o $(BUILD)/vbr vbr.asm

.PHONY: clean
clean:
	rm -rdf $(BUILD)
