MYDIR=$(dirname $0)

make image PROFILE=hlk7688a PACKAGES="mtd kmod-mtd-rw kmod-ikconfig -kmod-rt2800-pci -kmod-rt2800-soc -ppp -ppp-mod-pppoe -wpad-mini -wpad-basic -kmod-mt7603 -ip6tables -odhcp6c -odhcpd-ipv6only tcpdump usbutils kmod-usb2 kmod-usb-ohci serialconsole tio picocom uboot-envtools" FILES=$MYDIR/vm300_files/ V=s
