#!/bin/bash
echo Setting Function.
function getYN {
	local result
	while true; do
		read -p "$1 (Y/n) " result
		case $result in
			[Yy]* ) echo y; break;;
			[Nn]* ) echo n; break;;
		esac
	done
}
function getUrl {
	local result
	while true; do
		read -p 'Please enter URL:' result
		case $result in
			[hH][tT][tT][pP]{s,S,}://* ) echo $result; break;;
			'' ) echo ''; break;;
		esac
	done
}
function pause {
	echo -n 'To Continue, Press Enter.'
	read
}

echo 'Loading Config File (config.sh)'
if [ -f config.sh ]; then
	. config.sh
fi

if [ $IS_AUTO_INSTALL != y ]; then
	echo Read me!
	echo
	echo This is an install script for CSS.
	echo This script is being developing and
	echo it may need to suspend this script 
	echo to change config file and continue 
	echo the install.
	echo 
	echo Please make sure your computer have
	echo at least 300MB free ram memory for
	echo installation.
	echo 
	pause
fi

echo Setting Environment variable.
BASE_PATH=`pwd`
SAVE_STEP_PATH=${BASE_PATH}/step_info
TEMP=${BASE_PATH}/temp
BUILD=${BASE_PATH}/build
INITD_PATH=/etc/init.d/
INITD_NAME=CSS
START_SH=${TEMP}/start
STOP_SH=${TEMP}/stop
TEMP_STOP_SH=${TEMP}/temp_stop
OUTPUT_PATH=/usr/local/bin/CSS
MOUDLE_DIR=/var/JBOCD/module
#set proxy setting permanently
if [ "$IS_AUTO_INSTALL" != "y" ]; then
	SET_PROXY=`getYN 'Do You Want To Set Proxy?'` 
fi

if [ "$IS_AUTO_INSTALL" != "y" ] && [ "$SET_PROXY" = "y" ]; then
	if [ "`getYN "HTTP Proxy will set to $SET_HTTP_PROXY, Do You want to change?"`" = "y" ]; then
		SET_HTTP_PROXY=`getUrl`
	fi
	if [ "`getYN "HTTPS Proxy will set to $SET_HTTP_PROXY, Do You want to change?"`" = "y" ]; then
		SET_HTTPS_PROXY=`getUrl`
	fi
	if [ "`getYN "FTP Proxy will set to $SET_HTTP_PROXY, Do You want to change?"`" = "y" ]; then
		SET_FTP_PROXY=`getUrl`
	fi
	PERMANENT_PROXY=`getYN "Do You Want To Set Proxy Permanent?"`
fi

echo Starting installing

[ ! -d "$SAVE_STEP_PATH" ] && mkdir "$SAVE_STEP_PATH"
[ ! -d "$BUILD" ] && mkdir "$BUILD"
[ -d "$TEMP" ] && (sudo umount $TEMP; sudo rm -r $TEMP); mkdir $TEMP

sudo mount -t tmpfs -o size=300m tmpfs $TEMP
if [ "$SET_PROXY" = "y" ]; then
	echo Changing Proxy Setting
	cd "$SAVE_STEP_PATH"
	tmp=0
	if [ "`cat /etc/environment | grep http_proxy`" != "http_proxy=\"$SET_HTTP_PROXY\"" ]; then
		if [ "$PERNAMENT_PROXY" = "y" ]; then
			sudo bash -c "echo http_proxy=\"$SET_HTTP_PROXY\" >> /etc/environment"
			sudo bash -c "echo HTTP_PROXY=\"$SET_HTTP_PROXY\" >> /etc/environment"
			tmp=1
		fi
		export http_proxy=$SET_HTTP_PROXY
	fi
	if [ "`cat /etc/environment | grep https_proxy`" != "https_proxy=\"$SET_HTTPS_PROXY\"" ]; then
		if [ "$PERNAMENT_PROXY" = "y" ]; then
			sudo bash -c "echo https_proxy=\"$SET_HTTPS_PROXY\" >> /etc/environment"
			sudo bash -c "echo HTTPS_PROXY=\"$SET_HTTPS_PROXY\" >> /etc/environment"
			tmp=1
		fi
		export https_proxy=$SET_HTTPS_PROXY
	fi
	if [ "`cat /etc/environment | grep ftp_proxy`" != "ftp_proxy=\"$SET_FTP_PROXY\"" ]; then
		if [ "$PERNAMENT_PROXY" = "y" ]; then
			sudo bash -c "echo ftp_proxy=\"$SET_FTP_PROXY\" >> /etc/environment"
			sudo bash -c "echo FTP_PROXY=\"$SET_FTP_PROXY\" >> /etc/environment"
			tmp=1
		fi
		export ftp_proxy=$SET_FTP_PROXY
	fi
	if [ $tmp -eq 1 ]; then
		if [ "$IS_AUTO_INSTALL" != "y" ] && [ "$PERMANENT_PROXY" = "y" ]; then
			echo The System is update the proxy
			echo setting. After installing, please
			echo relogin this account to apply the
			echo setting for other program.
			echo 
			pause
		fi
	fi
fi

echo Installing Build Package.
sudo apt-get update -y
sudo apt-get upgrade -y
if [ ! -f ${SAVE_STEP_PATH}/lib-apt-install ]; then
	# for all
	sudo apt-get install build-essential git -y

	# for web server
	sudo apt-get install apache2 mysql-server-5.5 php5 php5-curl phpmyadmin -y

	# for json-c
	sudo apt-get install libjson0 libjson0-dev -y
#	sudo apt-get install libjson-glib-1.0-0 libjson-glib-dev -y

	#for mysql
	sudo apt-get install libmysqlcppconn-dev -y

	#for websocket
	sudo apt-get install openssl libssl-dev -y

	#for third party
	sudo apt-get install python python-setuptools python-pip -y

#	sudo apt-get isntall gcc clang libtool autoconf automake
	touch ${SAVE_STEP_PATH}/lib-apt-install
fi

echo Downloading JBOCD

#download procedure use file copy now
#change it
cd $BASE_PATH
cp -r server $TEMP/server
#...

echo Compiling JBOCD
cd $TEMP/server
sudo make clean BUILD=$BUILD
sudo make BUILD=$BUILD

echo Setting up JBOCD
[ ! -d /etc/JBOCD ] && sudo mkdir /etc/JBOCD
[ ! -d $MOUDLE_DIR ] && sudo mkdir $MOUDLE_DIR 
[ ! -d /usr/local/lib/JBOCD ] && sudo mkdir -p /usr/local/lib/JBOCD

sudo chown www-data:www-data -R /usr/local/lib/JBOCD
sudo chown www-data:www-data -R $MOUDLE_DIR
if [ ! "`sudo cat /etc/sudoers | grep \"www-data ALL = NOPASSWD: /usr/bin/python, NOPASSWD: /usr/bin/pip\"`" ]; then
	sudo bash -c "echo \"www-data ALL = NOPASSWD: /usr/bin/python, NOPASSWD: /usr/bin/pip\" >>/etc/sudoers"
fi

if [ ! -f /etc/JBOCD/config.json ]; then
	sudo cp config.json /etc/JBOCD/config.json
	sudo chmod 644 /etc/JBOCD/config.json
fi

echo "Installation completed"

cd $BASE_PATH
sudo umount $TEMP
rm -r $TEMP
exit 0
