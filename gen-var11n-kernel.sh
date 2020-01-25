#!/bin/bash
set -e

PROFILE=${PROFILE:-vonets_var11n-300}
BOARD=VAR11N-300
MYDIR=$(dirname $0)
PKERNEL=$PROFILE-kernel.bin
SDKDIR=${SDKDIR:-.}   # USE e.g. SDK_DIR=../../sdk/19.07rc2 to set other dir
LINUXDIR=build_dir/target-mipsel_24kc_musl/linux-ramips_mt7620
export STAGING_DIR=$SDKDIR/staging_dir
CPPPATH=$STAGING_DIR/toolchain-mipsel_24kc_gcc-7.5.0_musl/bin
[ -x $CPPPATH/mipsel-openwrt-linux-cpp ] || { echo "Please set proper SDKDIR"; exit 1; }
PATH=$CPPPATH:$PATH


mipsel-openwrt-linux-cpp -nostdinc -x assembler-with-cpp -I $SDKDIR/$LINUXDIR/linux-4.14.156/include -I target/linux/ramips/dts/ -undef -D__DTS__ -o $LINUXDIR/image-$BOARD.dtb.tmp $MYDIR/$BOARD.dts

$SDKDIR/$LINUXDIR/linux-4.14.156/scripts/dtc/dtc -O dtb -i../dts/ -Wno-unit_address_vs_reg -Wno-unit_address_vs_reg -Wno-simple_bus_reg -Wno-unit_address_format -Wno-pci_bridge -Wno-pci_device_bus_num -Wno-pci_device_reg  -o $LINUXDIR/image-$BOARD.dtb $LINUXDIR/image-$BOARD.dtb.tmp


rm -f $LINUXDIR/$PKERNEL
cp $LINUXDIR/vmlinux $LINUXDIR/$PKERNEL.pre
cat $LINUXDIR/image-$BOARD.dtb >> $LINUXDIR/$PKERNEL.pre

$STAGING_DIR/host/bin/lzma e $LINUXDIR/$PKERNEL.pre -lc1 -lp2 -pb2  $LINUXDIR/$PKERNEL.new
$STAGING_DIR/host/bin/mkimage -A mips -O linux -T kernel -C lzma -a 0x80000000 -e 0x80000000 -n 'MIPS OpenWrt Linux-4.14.156' -d $LINUXDIR/$PKERNEL.new $LINUXDIR/$PKERNEL
