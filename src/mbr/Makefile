BUILD_DIR = "$(BUILD)/mbr"

all: $(BUILD_DIR)/mbr

build: 
	mkdir -p $(BUILD_DIR)
	
$(BUILD_DIR)/mbr: mbr.asm mbr.inc build
	nasm -f bin -O0 -o $(BUILD_DIR)/mbr mbr.asm

.PHONY: clean
clean:
	rm -rdf $(BUILD_DIR)
