#!/bin/bash
losetup -o 0 --sizelimit 1073741824 /dev/loop70 $1/rootfs/rootfs.img -P
if [ -d "$1/target" ]; then  
rm -rf $1/target
fi

mkdir $1/target
mkdir $1/target/bootfs
mkdir $1/target/rootfs
mount /dev/loop70p1 $1/target/bootfs 
mount /dev/loop70p2 $1/target/rootfs

cp -r $1/bootfs/* $1/target/bootfs/
#cpy a user program for test
mkdir -p $1/target/rootfs/home
cp -r $1/rootfs/fake_init/init $1/target/rootfs/home/
#cpy busybox fot rootfs
cp -r $1/rootfs/bin $1/target/rootfs/
cp -r $1/rootfs/linuxrc $1/target/rootfs/
cp -r $1/rootfs/sbin $1/target/rootfs/
cp -r $1/rootfs/usr $1/target/rootfs/

mkdir -p $1/target/rootfs/etc/init.d
mkdir -p $1/target/rootfs/proc
mkdir -p $1/target/rootfs/tmp
mkdir -p $1/target/rootfs/sys/kernel/debug
mkdir -p $1/target/rootfs/dev
mkdir -p $1/target/rootfs/lib
mkdir -p $1/target/rootfs/usr/bin

cat > $1/target/rootfs/etc/fstab << EOF
proc			/proc								proc			defaults    0	0
none			/tmp								ramfs		defaults    0	0
sysfs			/sys								sysfs		defaults    0	0
mdev		    /dev								ramfs		defaults	0	0
debugfs	        /sys/kernel/debug 	                debugfs	    defaults    0   0
EOF
chmod a+x $1/target/rootfs/etc/fstab

cat > $1/target/rootfs/etc/init.d/rcS << EOF
#! /bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin

mount -a
/sbin/mdev -s
mount -a

echo "---------------------------------------------"
echo " Welcome debugging on Qemu Quard Star board! "
echo "---------------------------------------------"
EOF
chmod a+x $1/target/rootfs/etc/init.d/rcS

cat > $1/target/rootfs/etc/inittab << EOF
::sysinit:/etc/init.d/rcS
console::askfirst:-/bin/sh
EOF
chmod a+x $1/target/rootfs/etc/inittab

cat > $1/target/rootfs/etc/profile << EOF
# /etc/profile: system-wide .profile file for the Bourne shells

echo -n "Processing /etc/profile... "
# no-op
echo "Done"
EOF
chmod a+x $1/target/rootfs/etc/profile

#cpy .so
cp -a $2/lib/* $1/target/rootfs/lib/
cp -a $2/usr/bin/* $1/target/rootfs/usr/bin
cd $1/target/rootfs/
ln -sf lib lib64
cd -

sync

#rm -rf $1/rootfs/bin $1/rootfs/linuxrc $1/rootfs/sbin $1/rootfs/usr

umount $1/target/bootfs 
umount $1/target/rootfs
losetup -d /dev/loop70  
sync
