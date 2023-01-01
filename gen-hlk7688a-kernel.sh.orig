#!/bin/bash
set -e

PROFILE=${PROFILE:-hlk7688a}
BOARD=hlk-7688a
CHIP=mt76x8
MYDIR=$(dirname $0)
PKERNEL=$PROFILE-kernel.bin
SDKDIR=${SDKDIR:-.}   # USE e.g. SDK_DIR=../../sdk/19.07rc2 to set other dir
LINUXDIR=build_dir/target-mipsel_24kc_musl/linux-ramips_$CHIP
export STAGING_DIR=$SDKDIR/staging_dir
CPPPATH=$STAGING_DIR/toolchain-mipsel_24kc_gcc-7.5.0_musl/bin
[ -x $CPPPATH/mipsel-openwrt-linux-cpp ] || { echo "Please set proper SDKDIR"; exit 1; }
PATH=$CPPPATH:$PATH

SOCMK=target/linux/ramips/image/$CHIP.mk
[ -f $SOCMK ] || { echo "File $SOCMK not found. Check your imagebuilder"; exit 1; }
fgrep -q 'define Device/hlk7688a' $SOCMK || {
  echo "Patching $SOCMK"
  patch $SOCMK <<EOF
@@ -102,6 +102,15 @@
 endef
 TARGET_DEVICES += LinkIt7688
 
+define Device/hlk7688a
+  DTS := hlk-7688a
+  IMAGE_SIZE := \$(ralink_default_fw_size_32M)
+  SUPPORTED_DEVICES := fw_7688
+  DEVICE_TITLE := HiLink HLK-7688A based forwarder
+  DEVICE_PACKAGES:= kmod-usb2 kmod-usb-ohci uboot-envtools
+endef
+TARGET_DEVICES += hlk7688a
+
 define Device/mac1200r-v2
   DTS := MAC1200RV2
   DEVICE_TITLE := Mercury MAC1200R v2.0
EOF
}


fgrep -q DEVICE_${PROFILE}_SUPPORTED_DEVICES .profiles.mk || {
  echo "Regenerating .profiles.mk"
  mkdir -p tmp/info
  make -j1 -r -s -f include/scan.mk SCAN_TARGET="targetinfo" SCAN_DIR="target/linux" SCAN_NAME="target" SCAN_DEPTH=2 SCAN_EXTRA="" SCAN_MAKEOPTS="TARGET_BUILD=1" TOPDIR=$(pwd) V=s
  scripts/target-metadata.pl profile_mk tmp/.targetinfo ramips/$CHIP > .profiles.mk
}


mipsel-openwrt-linux-cpp -nostdinc -x assembler-with-cpp -I $SDKDIR/$LINUXDIR/linux-4.14.156/include -I target/linux/ramips/dts/ -undef -D__DTS__ -o $LINUXDIR/image-$BOARD.dtb.tmp $MYDIR/$BOARD.dts

$SDKDIR/$LINUXDIR/linux-4.14.156/scripts/dtc/dtc -O dtb -i../dts/ -Wno-unit_address_vs_reg -Wno-unit_address_vs_reg -Wno-simple_bus_reg -Wno-unit_address_format -Wno-pci_bridge -Wno-pci_device_bus_num -Wno-pci_device_reg  -o $LINUXDIR/image-$BOARD.dtb $LINUXDIR/image-$BOARD.dtb.tmp


rm -f $LINUXDIR/$PKERNEL
cp $LINUXDIR/vmlinux $LINUXDIR/$PKERNEL.pre
cat $LINUXDIR/image-$BOARD.dtb >> $LINUXDIR/$PKERNEL.pre

$STAGING_DIR/host/bin/lzma e $LINUXDIR/$PKERNEL.pre -lc1 -lp2 -pb2  $LINUXDIR/$PKERNEL.new
$STAGING_DIR/host/bin/mkimage -A mips -O linux -T kernel -C lzma -a 0x80000000 -e 0x80000000 -n 'MIPS OpenWrt Linux-4.14.156' -d $LINUXDIR/$PKERNEL.new $LINUXDIR/$PKERNEL
