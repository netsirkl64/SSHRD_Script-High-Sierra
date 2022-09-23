#!/usr/bin/env sh

set -e

if [[ -z $1 ]]; then

echo "1st argument: iOS version for the ramdisk"

exit

fi

sudo ./sshrd.sh clean
sudo ./sshrd.sh "$1" TrollStore Tips
sudo ./sshrd.sh boot

echo "              _                _       "
echo "  _ __   __ _| | ___ _ __ __ _/ |_ ___ "
echo " | |_ \ / _| | |/ _ \ |__/ _| | | |_  |"
echo " | |_) | (_| | |  __/ | | (_| | | | | |"
echo " | |__/ \__|_|_|\___|_|  \__|_|_|_| |_|"
echo " |_|"
echo ""
read -s -n 1 -p "Press [Enter] key when you see this on your phone . . ."
echo ""

sudo ./sshrd.sh dump-blobs > /dev/null
sudo ./sshrd.sh dump-blobs
