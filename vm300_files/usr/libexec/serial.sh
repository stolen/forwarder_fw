#!/bin/ash
trap '' 2 20

# default
PROG=tio

case $TERM in
sc|tio|pc|picocom)
	PROG=$TERM
	echo "Using user-specified program $PROG"
	;;
*)
	echo "You can pass TERM=sc|tio|pc|picocom to use specific terminal program. Your TERM=$TERM"
	;;
esac
	

BITRATE=$USER
DEVICE=/dev/ttyUSB0


case $PROG in
sc)
	sc -h 2>&1 | sed -n '/^available/,$d/^escape/,$p'
	exec sc -s $BITRATE $DEVICE
	;;
tio)
	exec tio -b $BITRATE $DEVICE
	;;
pc|picocom)
	exec picocom --baud $BITRATE $DEVICE
	;;
*)
	echo "unknown terminal command $PROG. Please fix $0"
	;;
esac
