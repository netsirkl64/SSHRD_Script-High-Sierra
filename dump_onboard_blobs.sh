#!/usr/bin/env sh

set -e

if [[ -z $1 ]]; then

echo "1st argument: iOS version for the ramdisk"

exit

fi

sudo ./sshrd.sh clean
sudo ./sshrd.sh "$1"
sudo ./sshrd.sh boot

echo "Press any key when the device is done loading ramdisk"
read -s -n 1 -p "Press any key to continue . . ."

sudo ./sshrd.sh dump-blobs > /dev/null
sudo ./sshrd.sh dump-blobs
