export HOME = $(shell pwd)
export BUILD = $(HOME)/build

all: build
	$(MAKE) -C src/boot all

build:
	mkdir build

image: all
	misc/make_image.sh $(BUILD)

.PHONY: clean
clean:
	$(MAKE) -C src/boot clean
	rm -f $(BUILD)/*
