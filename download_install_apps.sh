#!/bin/bash
# Created by Matthew Miller
# 19FEB2017
# Downloads, builds, and installs software to build an APRS Digipeater & iGate using aprx and soundmodem

APRX_BUILD_DIR=~/aprx_build

set -e

if [ "$(whoami)" != "root" ]; then
        echo "ERROR: This script be run as root!"
        exit 1
fi


#Install dependencies
echo '**** Installing dependencies ****'
apt-get -y install git build-essential soundmodem



#Create RTL-SDR directory
mkdir $APRX_BUILD_DIR



#Install APRS iGate software
echo '**** Fetching APRS iGate software ****'
cd $APRX_BUILD_DIR
git clone https://github.com/PhirePhly/aprx.git
cd aprx
echo '**** Building APRS iGate software ****'
./configure
make
echo '**** Installing APRS iGate software ****'
make install
ldconfig



#Install init.d script template
echo '**** Fetching init.d script template ****'
cd $APRX_BUILD_DIR
git clone https://github.com/fhd/init-script-template.git
cd init-script-template
echo '**** Configuring aprx init.d from template ****'
mkdir -p $APRX_BUILD_DIR/init.d
cp template $APRX_BUILD_DIR/init.d/aprx
cd $APRX_BUILD_DIR/init.d
sed -i 's|cmd=""|cmd="/sbin/aprx -i"|g' aprx
sed -i 's/user=""/user="aprx"/g' aprx
sed -i 's/# Required-Start:    $remote_fs $syslog/# Required-Start:    $remote_fs $syslog soundmodem/g' aprx
sed -i 's/# Provides:/# Provides: aprx/g' aprx
sed -i 's/# Description:       Enable service provided by daemon./# Description:       Starts aprx APRS Digipeater & iGate daemon/g' aprx
#echo '**** Installing aprx init.d ****'
cp aprx /etc/init.d/
useradd -r -s /sbin/nologin -M aprx
#adduser aprx audio


#Install second init.d script template
cd $APRX_BUILD_DIR
cd init-script-template
echo '**** Configuring soundmodem init.d from template ****'
mkdir -p $APRX_BUILD_DIR/init.d
cp template $APRX_BUILD_DIR/init.d/soundmodem
cd $APRX_BUILD_DIR/init.d
sed -i 's|cmd=""|cmd="/usr/sbin/soundmodem"|g' soundmodem
sed -i 's/user=""/user="root"/g' soundmodem
sed -i 's/# Provides:/# Provides: soundmodem/g' soundmodem
sed -i 's/# Description:       Enable service provided by daemon./# Description:       Starts soundmodem for aprx/g' soundmodem
#echo '**** Installing soundmodem init.d ****'
cp soundmodem /etc/init.d/
echo '**** NOTE: aprx init.d is set up but will not run'
echo '           on boot until you run configure script to enable it. ****'
echo ''
echo 'If you *REALLY* want to enable aprx init.d before you configure'
echo 'it, just run `sudo update-rc.d aprx defaults`.  Remember, you'
echo 'will first need to have configured the /etc/aprx.conf in'
echo 'addition to /etc/ax25/soundmodem.conf before you can run them!'
echo ''



#Done!
echo 'Install complete!'
