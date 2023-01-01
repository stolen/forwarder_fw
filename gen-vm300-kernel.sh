#!/bin/bash
set -e

PROFILE=${PROFILE:-vonets_vm300}
BOARD=VM300
MYDIR=$(dirname $0)
PKERNEL=$PROFILE-kernel.bin
SDKDIR=${SDKDIR:-.}   # USE e.g. SDK_DIR=../../sdk/19.07rc2 to set other dir
LINUXDIR=build_dir/target-mipsel_24kc_musl/linux-ramips_mt7620
export STAGING_DIR=$SDKDIR/staging_dir
CPPPATH=$STAGING_DIR/toolchain-mipsel_24kc_gcc-7.5.0_musl/bin
[ -x $CPPPATH/mipsel-openwrt-linux-cpp ] || { echo "Please set proper SDKDIR"; exit 1; }
PATH=$CPPPATH:$PATH

SOCMK=target/linux/ramips/image/mt7620.mk
[ -f $SOCMK ] || { echo "File $SOCMK not found. Check your imagebuilder"; exit 1; }
fgrep -q 'define Device/vonets_vm300' $SOCMK || {
  echo "Patching $SOCMK"
  patch $SOCMK <<EOF
@@ -659,6 +659,14 @@
 endef
 TARGET_DEVICES += vonets_var11n-300
 
+define Device/vonets_vm300
+  DTS := VM300
+  IMAGE_SIZE := \$(ralink_default_fw_size_8M)
+  BLOCKSIZE := 4k
+  DEVICE_TITLE := Vonets VM300
+endef
+TARGET_DEVICES += vonets_vm300
+
 define Device/ravpower_wd03
   DTS := WD03
   IMAGE_SIZE := \$(ralink_default_fw_size_8M)
EOF
}


fgrep -q DEVICE_${PROFILE}_SUPPORTED_DEVICES .profiles.mk || {
  echo "Regenerating .profiles.mk"
  mkdir -p tmp/info
  make -j1 -r -s -f include/scan.mk SCAN_TARGET="targetinfo" SCAN_DIR="target/linux" SCAN_NAME="target" SCAN_DEPTH=2 SCAN_EXTRA="" SCAN_MAKEOPTS="TARGET_BUILD=1" TOPDIR=$(pwd) V=s
  scripts/target-metadata.pl profile_mk tmp/.targetinfo ramips/mt7620 > .profiles.mk
}


mipsel-openwrt-linux-cpp -nostdinc -x assembler-with-cpp -I $SDKDIR/$LINUXDIR/linux-*/include -I target/linux/ramips/dts/ -undef -D__DTS__ -o $LINUXDIR/image-$BOARD.dtb.tmp $MYDIR/$BOARD.dts

$SDKDIR/$LINUXDIR/linux-*/scripts/dtc/dtc -O dtb -i../dts/ -Wno-unit_address_vs_reg -Wno-unit_address_vs_reg -Wno-simple_bus_reg -Wno-unit_address_format -Wno-pci_bridge -Wno-pci_device_bus_num -Wno-pci_device_reg  -o $LINUXDIR/image-$BOARD.dtb $LINUXDIR/image-$BOARD.dtb.tmp


rm -f $LINUXDIR/$PKERNEL
cp $LINUXDIR/vmlinux $LINUXDIR/$PKERNEL.pre
cat $LINUXDIR/image-$BOARD.dtb >> $LINUXDIR/$PKERNEL.pre

$STAGING_DIR/host/bin/lzma e $LINUXDIR/$PKERNEL.pre -lc1 -lp2 -pb2  $LINUXDIR/$PKERNEL.new
$STAGING_DIR/host/bin/mkimage -A mips -O linux -T kernel -C lzma -a 0x80000000 -e 0x80000000 -n 'MIPS OpenWrt Linux' -d $LINUXDIR/$PKERNEL.new $LINUXDIR/$PKERNEL
