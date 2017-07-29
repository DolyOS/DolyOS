#! /bin/bash

BUILD=$1

# Allocate image file
image="$BUILD/harddisk.vmdk"
if [ ! -e $image ]; then
    dd bs=512 count=65536 if=/dev/zero of=$image status=none
fi

# Copy MBR to the first sector
dd bs=512 count=1 if=$BUILD/boot/mbr/mbr of=$image conv=notrunc status=none

# Create ext2 partition
printf "n\np\n\n\n\na\nw\n" | fdisk $image >/dev/null
device=$(losetup --partscan --show --find $image)  # Create loop device for the image file
# mkfs -t ext2 $device"p1"

# Copy VBR to the first 2 sectors of the volume
# dd bs=512 count=2 if=$BUILD/boot/vbr/vbr of=$device"p1" conv=notrunc status=none

# Delete the loop device of the image file
# losetup -d $device
