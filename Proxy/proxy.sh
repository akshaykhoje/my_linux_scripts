#!/bin/bash

global_proxy="/etc/profile.d/proxy.sh"
wget_proxy="/etc/wgetrc"
apt_proxy="/etc/apt/apt.conf.d/80proxy"


toggleProxyON()
{	
	echo "Turning proxy ON"
	#gsettings set org.gnome.system.proxy mode manual
	sudo sed -i 's/#//g' "$global_proxy" "$wget_proxy" "$apt_proxy"
	. $global_proxy
	exit 0
}


toggleProxyOFF()
{
	if read -n1 char <"$global_proxy"; [[ $char = "#" ]]; then
	  echo "$PROXY ALREADY OFF"
	  exit 0
	fi
	
	echo "Turning proxy OFF"
	#gsettings set org.gnome.system.proxy mode manual
	sudo sed -i 's/^/#/' "$global_proxy" "$wget_proxy" "$apt_proxy"
	
	#if [ -f /etc/profile.d/unset_proxy.sh ]; then
	#sudo sed -i 's/^/#/' "$global_proxy"
	. $global_proxy
	#fi
	exit 0
}


# if [ "$#" -ne 1 ];
# then
	# echo "$0: exactly 1 argument is expected!"
	# exit 3
# fi

case $1 in
	"on")
		toggleProxyON
		;;
	"off")
		toggleProxyOFF
		;;
esac

# if [ $1="on" ];
# then
	# toggleProxyON
	# exit 0
# fi
# 
# if [ $1="off" ];
# then
	# toggleProxyOFF
	# exit 0
# fi
# 
