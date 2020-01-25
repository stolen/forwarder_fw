MYDIR=$(dirname $0)

make image PROFILE=vonets_var11n-300 PACKAGES="kmod-ikconfig -kmod-rt2800-pci -kmod-rt2800-soc -ppp -ppp-mod-pppoe -wpad-mini -wpad-basic -kmod-mt76 -ip6tables -odhcp6c -odhcpd-ipv6only tcpdump kmod-usb-serial-cp210x usbutils kmod-usb2 kmod-usb-ohci serialconsole tio picocom kmod-mtd-rw uboot-envtools" FILES=$MYDIR/vm300_files/ V=s
