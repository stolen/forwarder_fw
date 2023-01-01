IFILES=${FILES:-$(dirname $0)/vm300_files/}
IPROFILE=${PROFILE:-hlk7688a}

make image PROFILE=$IPROFILE PACKAGES="\
   mtd kmod-mtd-rw kmod-ikconfig \
   -kmod-rt2800-pci -kmod-rt2800-soc -ppp -ppp-mod-pppoe -wpad-mini -wpad-basic -kmod-mt7603 \
   -ip6tables -odhcp6c -odhcpd-ipv6only -urngd \
   tcpdump usbutils kmod-usb2 kmod-usb-ohci \
   serialconsole tio picocom uboot-envtools \
   libgpiod gpiod-tools $EXTRAPKGS"\
  FILES=$IFILES V=s
