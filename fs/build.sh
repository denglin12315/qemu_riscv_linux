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
mkdir -p $1/target/rootfs/home/ldeng
mkdir -p $1/target/rootfs/home/root

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
LD_LIBRARY_PATH=/lib
export PATH LD_LIBRARY_PATH

mount -a
/sbin/mdev -s
mount -a

echo QEMU-QUARD-STAR > /proc/sys/kernel/hostname

dmesg -n 1
chmod 666 /dev/null

echo "---------------------------------------------"
echo " Welcome debugging on Qemu Quard Star board! "
echo "---------------------------------------------"
EOF
chmod a+x $1/target/rootfs/etc/init.d/rcS

cat > $1/target/rootfs/etc/inittab << EOF
::sysinit:/etc/init.d/rcS
console::respawn:/sbin/getty 38400 console
console::restart:/sbin/init
console::ctrlaltdel:/sbin/reboot
EOF
chmod a+x $1/target/rootfs/etc/inittab

cat > $1/target/rootfs/etc/profile << EOF
# /etc/profile: system-wide .profile file for the Bourne shells

echo -n "Processing /etc/profile... "
source ~/.bashrc
echo "Done"
EOF
chmod a+x $1/target/rootfs/etc/profile

#cpy .so
cp -a $2/lib/* $1/target/rootfs/lib/
cp -a $2/usr/bin/* $1/target/rootfs/usr/bin
cd $1/target/rootfs/
ln -sf lib lib64
cd -

cat > $1/target/rootfs/etc/shadow  <<EOF
root:8f3SuzAlYA9zc:18802:0:99999:7:::
daemon:*:16092:0:99999:7:::
bin:*:16092:0:99999:7:::
sys:*:16092:0:99999:7:::
nobody:*:16092:0:99999:7:::
ldeng:8KRJzPtwP/eRQ:18802:0:99999:7:::
EOF

cat > $1/target/rootfs/etc/passwd  <<EOF
root:x:0:0:root:/home/root:/bin/sh
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
ldeng:x:1000:1000:Linux User,,,:/home/ldeng:/bin/sh
EOF

cat > $1/target/rootfs/etc/group  <<EOF
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
sudo:x:27:ldeng
users:x:100:
nogroup:x:65534:
ldeng:x:1000:
EOF

cat > $1/target/rootfs/home/root/.bashrc <<EOF
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
LD_LIBRARY_PATH=/lib
export PATH LD_LIBRARY_PATH
alias ll='ls -lt'
EOF

cat > $1/target/rootfs/home/ldeng/.bashrc <<EOF
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
LD_LIBRARY_PATH=/lib
export PATH LD_LIBRARY_PATH
alias ll='ls -lt'
EOF

cat > $1/target/rootfs/etc/busybox.conf <<EOF
[SUID]
su = ssx 0.0 # run with euid=0/egid=0
id = ssx 0.0 # run with euid=0/egid=0
halt = ssx 0.0 # run with euid=0/egid=0
reboot = ssx 0.0 # run with euid=0/egid=0
shutdown= ssx 0.0 # run with euid=0/egid=0
passwd = --- 0.0 # disabled for all user except for root
EOF

sync

umount $1/target/bootfs 
umount $1/target/rootfs
losetup -d /dev/loop70  
sync
