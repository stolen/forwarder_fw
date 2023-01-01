#!/bin/ash

dev=1
ADDR=`gpiofind DEV-$dev-PWR`
[[ -z "$ADDR" ]] && exit 7

on()
{
	gpioset $ADDR=1
}

off()
{
	gpioset $ADDR=0
}

exec_command()
{
	case $1 in
	on)
		on
		echo " -> on"
		;;
	off)
		off
		echo " -> off"
		;;
	reset)
		off
		echo -n " -> off ..."
		sleep ${2:-2} # 2 seconds default
		on
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
