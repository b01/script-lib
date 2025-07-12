#!/bin/sh

set -e

# Find all drives

# Of course, that'll fail to find network-attached storage: lsdev, lsusb and lspci.
ls -l /dev /dev/mapper | grep '^b'/proc/partitions

# Mount the partition to an existing mount point (directory).
mkdir -p /mnt/myusb

mount -t vfat -o rw,users /dev/sda1 /mnt/myusb
