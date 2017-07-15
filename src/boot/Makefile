BUILD := $(BUILD)/boot

all: $(BUILD)/boot

$(BUILD): 
	mkdir -p $(BUILD)
	
$(BUILD)/boot: $(BUILD) 
	$(MAKE) -C mbr all
	$(MAKE) -C vbr all

.PHONY: clean
clean:
	rm -rdf $(BUILD)
