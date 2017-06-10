export HOME = $(shell pwd)
export BUILD = $(HOME)/build

all: build
	$(MAKE) -C src/mbr all

build:
	mkdir build

.PHONY: clean
clean:
	$(MAKE) -C src/mbr clean