#!/bin/bash

echo "-------------------------------------------------------------"
echo "Welcome to the proxy setup program!"
echo "-------------------------------------------------------------"
echo ""

PCUSER="$(whoami)"

echo "Initializing proxy setup process..."
echo "Enter the IP address for your proxy server : "
read proxy
echo "Enter the port number : "
read port
echo "Enter the username (your MIS) : "
read username
echo "Enter the password : "
read password

echo "display information given so far..."
echo "proxy : $proxy, port : $port, username : $username, password : $password"

if [[ -z $proxy ]] || [[ -z $port ]] || [[ -z username ]] || [[ -z password ]]; then
	echo "Please enter the proper credentials"
	exit 0
fi

echo "NOTE :

The proxy setup requires to be done in 4 phases - 

1. Manually configuring the proxy in Settings -> Network -> Network Proxy -> Manual -> \"Enter credentials\"
2. Set system-wide proxy settings 
3. Set proxy for APT package manager
4. Set proxy for wget CLI only

You need to complete the first step before moving to the second before you can actually connect to the internet from the terminal or even browser when behind a proxy.

Manually fill in the proxy settings as told above.

The steps 2, 3 and 4 have been automated using this interactive script written in bash. 

Let's begin...
"

echo "Setting up global proxy in /etc/profile.d/proxy.sh"

touch /etc/profile.d/proxy.sh       
path_to_global_proxy="/etc/profile.d/proxy.sh"    

# to unset variables
unset_vars="/etc/profile.d/unset_proxy.sh"
sudo touch /etc/profile.d/unset_proxy.sh
cat <<EOF > $unset_vars
#!/bin/bash

unset no_proxy
unset ftp_proxy
unset https_proxy
unset NO_PROXY
unset FTP_PROXY
unset HTTPS_PROXY
unset HTTP_PROXY
unset http_proxy
EOF

cat <<EOF > $path_to_global_proxy
# set proxy config via profile.d - should apply for all users
# For http/https/ftp/no_proxy


export http_proxy="http://$username:$password@$proxy:$port/"
export https_proxy="http://$username:$password@$proxy:$port/"
export ftp_proxy="http://$username:$password@$proxy:$port/"
export no_proxy="127.0.0.1,localhost"


# For curl
export HTTP_PROXY="http://$username:$password@$proxy:$port/"
export HTTPS_PROXY="http://$username:$password@$proxy:$port/"
export FTP_PROXY="http://$username:$password@$proxy:$port/"
export NO_PROXY="127.0.0.1,localhost"
EOF

echo "The proxy file created needs to be sourced. Do you wish to continue? (y/n)"
read choice

#if [ $choice = "y" ]; then 
#	source $path_to_global_proxy

if [ $choice = 'y' ]; then 
	source $path_to_global_proxy

	echo "To check if the proxy variables have been initialized, enter the following command on the terminal : "
	echo "env | grep -i proxy"
elif [ $choice = "n" ]; then
	sudo rm $path_to_global_proxy
	printf "\\n exiting..."
	exit 0
fi

echo "
Completed step 2. Initializing step 3."

touch /etc/apt/apt.conf.d/80proxy       

apt_proxy="/etc/apt/apt.conf.d/80proxy"	

cat <<EOF > $apt_proxy
Acquire::http::proxy "http://$username:$password@$proxy:$port/";
Acquire::https::proxy "http://$username:$password@$proxy:$port/";
Acquire::ftp::proxy "http://$username:$password@$proxy:$port/";
EOF

echo "
Completed step 3. Initializing the final step."

touch /home/"$PCUSER"/.wgetrc
wget_proxy="/home/"$PCUSER"/.wgetrc"
     
cat <<EOF > $wget_proxy
use_proxy = on
http_proxy = http://$username:$password@$proxy:$port/
https_proxy = http://$username:$password@$proxy:$port/
ftp_proxy = http://$username:$password@$proxy:$port/
EOF

echo "Completed the final step"


echo "--------------------------------------------------------------------------------------"

echo "
Since you are behind a proxy server, you cannot use the ping command. So you have to install httping to ensure that your proxy server is running."

echo "
Install httping using \"sudo apt install httping\"."

echo "
Now try running the following commands to check that your proxy is up and running:"

echo "
httping -x <proxy>:<port> -g google.com"

echo "
Check your curl and wget by trying out those commands"

echo "
In case of any issues/errors, feel free to contact."

echo "
Thank you!"

exit 0
