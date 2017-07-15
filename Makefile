export HOME = $(shell pwd)
export BUILD = $(HOME)/build

all: build
	$(MAKE) -C src/boot all

build:
	mkdir build

$(BUILD)/harddisk.vmdk: all
	dd bs=512 count=65536 if=/dev/zero of=$(BUILD)/harddisk.vmdk iflag=binary oflag=binary status=none

image: $(BUILD)/harddisk.vmdk
	dd bs=512 count=1 if=$(BUILD)/boot/mbr/mbr of=$(BUILD)/harddisk.vmdk iflag=binary oflag=binary conv=notrunc status=none
	dd bs=512 count=1 seek=128 if=$(BUILD)/boot/vbr/vbr of=$(BUILD)/harddisk.vmdk iflag=binary oflag=binary conv=notrunc status=none

.PHONY: clean
clean:
	$(MAKE) -C src/boot clean
	rm -f $(BUILD)/*
