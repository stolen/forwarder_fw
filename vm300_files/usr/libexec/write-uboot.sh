#!/bin/ash
[ -f "$1" ] || { echo "Usage: $0 /path/to/uboot.bin (see /usr/share/uboot for prebuilt images)"; exit 1; }

insmod mtd-rw i_want_a_brick=1
mtd unlock u-boot
mtd -r write "$1" u-boot

