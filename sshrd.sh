#!/bin/bash

chmod +x macos/*


: ${1?"1st argument: ipsw link"}
: ${2?"2nd argument: board cfg, can be iphone6 for example too (no AP part, lowercase)"}
: ${3?"3rd argument: can be any shsh blob, just make sure it's from the same ecid as your phone"}
: ${4?"4th argument: iv and key combined together for the ibss from the ipsw link you provided. You can get them from the iphonewiki"}
: ${5?"5th argument: iv and key combined together for the ibec from the ipsw link you provided. You can get them from the iphonewiki"}
: ${6?"6th argument: due to the fact i have no idea how to parse a BuildManifest in a shell script, please provide the filename of the restore ramdisk dmg here"}
: ${7?"7th argument: here too, i have no idea how to parse the BuildManifest, please provide kernelcache filename"}

img4tool -e -s $3 -m IM4M
macos/pzb -g BuildManifest.plist $1 1> /dev/null
macos/pzb -g Firmware/dfu/iBSS.$2.RELEASE.im4p $1
macos/pzb -g Firmware/dfu/iBEC.$2.RELEASE.im4p $1
macos/pzb -g Firmware/all_flash/DeviceTree.$2ap.im4p $1
macos/pzb -g Firmware/$6.trustcache $1
macos/pzb -g $7 $1
macos/pzb -g $6 $1
macos/img4 -i iBSS.$2.RELEASE.im4p -o iBSS.dec -k $4
macos/img4 -i iBEC.$2.RELEASE.im4p -o iBEC.dec -k $5
macos/iBoot64Patcher iBSS.dec iBSS.patched
macos/img4 -i iBSS.patched -o iBSS.img4 -M IM4M -A -T ibss
macos/iBoot64Patcher iBEC.dec iBEC.patched -b "rd=md0 -v wdt=-9999999"
macos/img4 -i iBEC.patched -o iBEC.img4 -M IM4M -A -T ibec
macos/img4 -i $7 -o kcache.raw
macos/Kernel64Patcher kcache.raw kcache.patched -a
python3 kerneldiff.py kcache.raw kcache.patched
macos/img4 -i $7 -o kernelcache.img4 -M IM4M -T rkrn -P kc.bpatch
macos/img4 -i DeviceTree.$2ap.im4p -o devicetree.img4 -M IM4M -T rdtr
macos/img4 -i $6.trustcache -o trustcache.img4 -M IM4M -T rtsc
macos/img4 -i $6 -o ramdisk.dmg
hdiutil resize -size 120MB ramdisk.dmg
hdiutil attach -mountpoint /tmp/SSHRD ramdisk.dmg
macos/gtar -x --no-overwrite-dir -f ssh.tar -C /tmp/SSHRD/
macos/ldid -Sdd_ent.xml /tmp/SSHRD/bin/dd
macos/ldid -Sent.xml /tmp/SSHRD/sbin/mount
macos/ldid -M -Sent.xml /tmp/SSHRD/bin/*
macos/ldid -M -Sent.xml /tmp/SSHRD/usr/bin/*
macos/ldid -M -Sent.xml /tmp/SSHRD/usr/sbin/*
macos/ldid -M -Sent.xml /tmp/SSHRD/usr/local/bin/*
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/apfs*
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/mount_apfs
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/slurpAPFSMeta
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/newfs_apfs
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/fsck_apfs
macos/ldid -M -Sent.xml /tmp/SSHRD/System/Library/Filesystems/apfs.fs/hfs_convert
hdiutil detach -force /tmp/SSHRD
hdiutil resize -sectors min ramdisk.dmg
macos/img4 -i ramdisk.dmg -o ramdisk.img4 -M IM4M -A -T rdsk
mv ramdisk.img4 sshramdisk
mv trustcache.img4 sshramdisk
mv devicetree.img4 sshramdisk
mv kernelcache.img4 sshramdisk
mv iBEC.img4 sshramdisk
mv iBSS.img4 sshramdisk
echo "we are done, please use boot.sh to boot your device"
echo cleanup...
rm iBSS.$2.RELEASE.im4p
rm iBEC.$2.RELEASE.im4p 
rm iBSS.dec
rm iBEC.dec
rm iBSS.patched
rm iBEC.patched
rm $7
rm $6
rm $6.trustcache
rm BuildManifest.plist
rm kcache.raw
rm kcache.patched
rm DeviceTree.$2ap.im4p
rm IM4M
rm kc.bpatch
touch kc.bpatch
rm ramdisk.dmg