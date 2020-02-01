#!/bin/ash

pin=0
valuepath=/sys/class/gpio/gpio$pin/value
#echo "managing pin $pin"

exec_command()
{
	case $1 in
	on)
		echo 1 >$valuepath
		echo " -> on"
		;;
	off)
		echo 0 >$valuepath
		echo " -> off"
		;;
	reset)
		echo 0 >$valuepath
		echo -n " -> off ..."
		sleep ${2:-2} # 2 seconds default
		echo 1 >$valuepath
		echo " -> on"
		;;
	*)
		echo "Invalid value $1. Accepted values: on|off|reset|reset [0-9]"
		;;
	esac
}


if [ "$1" = "-c" ]; then
	exec_command $2
	exit 0
fi

echo "Interactive mode. Commands: on|off|reset|reset [0-9]"
echo -n "> "
while read cmd; do
	[ -n "$cmd" ] && exec_command $cmd
	echo -n "> "
done
