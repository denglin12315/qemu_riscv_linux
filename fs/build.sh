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
mkdir -p $1/target/rootfs/mnt
mkdir -p $1/target/rootfs/usr/bin
mkdir -p $1/target/rootfs/usr/lib
mkdir -p $1/target/rootfs/home/ldeng
mkdir -p $1/target/rootfs/home/root
mkdir -p $1/target/rootfs/usr/share/udhcpc
mkdir -p $1/target/rootfs/etc/network/if-pre-up.d
mkdir -p $1/target/rootfs/etc/network/if-up.d
mkdir -p $1/target/rootfs/etc/network/if-down.d
mkdir -p $1/target/rootfs/etc/network/if-post-down.d
mkdir -p $1/target/rootfs/var/run/

touch $1/target/rootfs/var/run/ifstate.new


cat > $1/target/rootfs/usr/share/udhcpc/default.script << "EOF"
#!/bin/sh

# udhcpc script edited by Tim Riker <Tim@Rikers.org>

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

RESOLV_CONF="/etc/resolv.conf"
[ -e $RESOLV_CONF ] || touch $RESOLV_CONF
[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"
# Handle stateful DHCPv6 like DHCPv4
[ -n "$ipv6" ] && ip="$ipv6/128"

if [ -z "${IF_WAIT_DELAY}" ]; then
	IF_WAIT_DELAY=10
fi

wait_for_ipv6_default_route() {
	printf "Waiting for IPv6 default route to appear"
	while [ $IF_WAIT_DELAY -gt 0 ]; do
		if ip -6 route list | grep -q default; then
			printf "\n"
			return
		fi
		sleep 1
		printf "."
		: $((IF_WAIT_DELAY -= 1))
	done
	printf " timeout!\n"
}

case "$1" in
	deconfig)
		/sbin/ifconfig $interface up
		/sbin/ifconfig $interface 0.0.0.0

		# drop info from this interface
		# resolv.conf may be a symlink to /tmp/, so take care
		TMPFILE=$(mktemp)
		grep -vE "# $interface\$" $RESOLV_CONF > $TMPFILE
		cat $TMPFILE > $RESOLV_CONF
		rm -f $TMPFILE

		if [ -x /usr/sbin/avahi-autoipd ]; then
			/usr/sbin/avahi-autoipd -c $interface && /usr/sbin/avahi-autoipd -k $interface
		fi
		;;

	leasefail|nak)
		if [ -x /usr/sbin/avahi-autoipd ]; then
			/usr/sbin/avahi-autoipd -c $interface || /usr/sbin/avahi-autoipd -wD $interface --no-chroot
		fi
		;;

	renew|bound)
		if [ -x /usr/sbin/avahi-autoipd ]; then
			/usr/sbin/avahi-autoipd -c $interface && /usr/sbin/avahi-autoipd -k $interface
		fi
		/sbin/ifconfig $interface $ip $BROADCAST $NETMASK
		if [ -n "$ipv6" ] ; then
			wait_for_ipv6_default_route
		fi

		# RFC3442: If the DHCP server returns both a Classless
		# Static Routes option and a Router option, the DHCP
		# client MUST ignore the Router option.
		if [ -n "$staticroutes" ]; then
			echo "deleting routers"
			route -n | while read dest gw mask flags metric ref use iface; do
				[ "$iface" != "$interface" -o "$gw" = "0.0.0.0" ] || \
					route del -net "$dest" netmask "$mask" gw "$gw" dev "$interface"
			done

			# format: dest1/mask gw1 ... destn/mask gwn
			set -- $staticroutes
			while [ -n "$1" -a -n "$2" ]; do
				route add -net "$1" gw "$2" dev "$interface"
				shift 2
			done
		elif [ -n "$router" ] ; then
			echo "deleting routers"
			while route del default gw 0.0.0.0 dev $interface 2> /dev/null; do
				:
			done

			for i in $router ; do
				route add default gw $i dev $interface
			done
		fi

		# drop info from this interface
		# resolv.conf may be a symlink to /tmp/, so take care
		TMPFILE=$(mktemp)
		grep -vE "# $interface\$" $RESOLV_CONF > $TMPFILE
		cat $TMPFILE > $RESOLV_CONF
		rm -f $TMPFILE

		# prefer rfc3397 domain search list (option 119) if available
		if [ -n "$search" ]; then
			search_list=$search
		elif [ -n "$domain" ]; then
			search_list=$domain
		fi

		[ -n "$search_list" ] &&
			echo "search $search_list # $interface" >> $RESOLV_CONF

		for i in $dns ; do
			echo adding dns $i
			echo "nameserver $i # $interface" >> $RESOLV_CONF
		done
		;;
esac

HOOK_DIR="$0.d"
for hook in "${HOOK_DIR}/"*; do
    [ -f "${hook}" -a -x "${hook}" ] || continue
    "${hook}" "${@}"
done

exit 0
EOF
chmod a+x $1/target/rootfs/usr/share/udhcpc/default.script

cat > $1/target/rootfs/etc/resolv.conf << "EOF"
../tmp/resolv.conf
EOF
chmod a+x $1/target/rootfs/etc/resolv.conf

cat > $1/target/rootfs/etc/network/nfs_check << "EOF"
#!/bin/sh

# This allows NFS booting to work while also being able to configure
# the network interface via DHCP when not NFS booting.  Otherwise, a
# NFS booted system will likely hang during DHCP configuration.

# Attempting to configure the network interface used for NFS will
# initially bring that network down.  Since the root filesystem is
# accessed over this network, the system hangs.

# This script is run by ifup and will attempt to detect if a NFS root
# mount uses the interface to be configured (IFACE), and if so does
# not configure it.  This should allow the same build to be disk/flash
# booted or NFS booted.

nfsip=`sed -n '/^[^ ]*:.* \/ nfs.*[ ,]addr=\([0-9.]\+\).*/s//\1/p' /proc/mounts`
if [ -n "$nfsip" ] && ip route get to "$nfsip" | grep -q "dev $IFACE"; then
	echo Skipping $IFACE, used for NFS from $nfsip
	exit 1
fi
EOF
chmod a+x $1/target/rootfs/etc/network/nfs_check

cat > $1/target/rootfs/etc/network/interfaces << "EOF"
# interface file auto-generated by buildroot

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
  pre-up /etc/network/nfs_check
  wait-delay 15
  hostname $(hostname)
EOF
chmod a+x $1/target/rootfs/etc/network/interfaces

cat > $1/target/rootfs/etc/network/if-pre-up.d/wait_iface << "EOF"
#!/bin/sh

# In case we have a slow-to-appear interface (e.g. eth-over-USB),
# and we need to configure it, wait until it appears, but not too
# long either. IF_WAIT_DELAY is in seconds.

if [ "${IF_WAIT_DELAY}" -a ! -e "/sys/class/net/${IFACE}" ]; then
    printf "Waiting for interface %s to appear" "${IFACE}"
    while [ ${IF_WAIT_DELAY} -gt 0 ]; do
        if [ -e "/sys/class/net/${IFACE}" ]; then
            printf "\n"
            exit 0
        fi
        sleep 1
        printf "."
        : $((IF_WAIT_DELAY -= 1))
    done
    printf " timeout!\n"
    exit 1
fi
EOF
chmod a+x $1/target/rootfs/etc/network/if-pre-up.d/wait_iface

cat > $1/target/rootfs/etc/fstab << "EOF"
proc			/proc								proc			defaults    0	0
none			/tmp								ramfs		defaults    0	0
sysfs			/sys								sysfs		defaults    0	0
mdev		    /dev								ramfs		defaults	0	0
debugfs	        /sys/kernel/debug 	                debugfs	    defaults    0   0
EOF
chmod a+x $1/target/rootfs/etc/fstab

cat > $1/target/rootfs/etc/init.d/rcS << "EOF"
#! /bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export PATH LD_LIBRARY_PATH

mount -a
/sbin/mdev -s
mount -a
mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/

/bin/hostname -F /etc/hostname

dmesg -n 1
chmod 666 /dev/null

for i in /etc/init.d/S??* ;do
     [ ! -f "$i" ] && continue
     case "$i" in
	*.sh)
	    (
		trap - INT QUIT TSTP
		set start
		echo "ldeng:$i"
		. $i
	    )
	    ;;
	*)
	    $i start
	    echo "ldeng2:$i"
	    ;;
    esac
done

echo "---------------------------------------------"
echo " Welcome debugging on Qemu Quard Star board! "
echo "---------------------------------------------"
EOF
chmod a+x $1/target/rootfs/etc/init.d/rcS

cat > $1/target/rootfs/etc/inittab << "EOF"
::sysinit:/etc/init.d/rcS
console::respawn:/sbin/getty 38400 console
::ctrlaltdel:/sbin/reboot
::shutdown:/etc/init.d/rcK
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
::restart:/sbin/init
EOF
chmod a+x $1/target/rootfs/etc/inittab

cat > $1/target/rootfs/etc/init.d/S40network << "EOF"
#!/bin/bash

mkdir -p /run/network

case "$1" in
  start)
	echo "Starting network... "
	/sbin/ifup -a
	[ $? = 0 ] && echo "OK" || echo "FAIL"
	;;
  stop)
	echo "Stopping network... "
	/sbin/ifdown -a
	[ $? = 0 ] && echo "OK" || echo "FAIL"
	;;
  restart|reload)
	"$0" stop
	"$0" start
	;;
  *)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac

exit $?
EOF
chmod a+x $1/target/rootfs/etc/init.d/S40network

cat > $1/target/rootfs/etc/init.d/rcK << "EOF"
for i in $(ls -r /etc/init.d/S??*) ;do
     [ ! -f "$i" ] && continue
     case "$i" in
	*.sh)
	    (
		trap - INT QUIT TSTP
		set stop
		. $i
	    )
	    ;;
	*)
	    $i stop
	    ;;
    esac
done
EOF
chmod a+x $1/target/rootfs/etc/init.d/rcK

cat > $1/target/rootfs/etc/profile << "EOF"
# /etc/profile: system-wide .profile file for the Bourne shells

echo -n "Processing /etc/profile... "
source ~/.bashrc
echo "Done"
EOF
chmod a+x $1/target/rootfs/etc/profile

#cpy .so
cp -a $2/lib/* $1/target/rootfs/lib/
cp -a $2/usr/bin/* $1/target/rootfs/usr/bin
cp -a $2/usr/lib/* $1/target/rootfs/usr/lib/
cd $1/target/rootfs/
ln -sf lib lib64
cd -

cp -a /usr/share/zoneinfo $1/target/rootfs/usr/share/
cd $1/target/rootfs/
ln -sf usr/share/zoneinfo/Asia/Shanghai etc/localtime
cd -

cat > $1/target/rootfs/etc/shadow  << "EOF"
root:8f3SuzAlYA9zc:18802:0:99999:7:::
daemon:*:16092:0:99999:7:::
bin:*:16092:0:99999:7:::
sys:*:16092:0:99999:7:::
nobody:*:16092:0:99999:7:::
ldeng:8KRJzPtwP/eRQ:18802:0:99999:7:::
EOF

cat > $1/target/rootfs/etc/passwd  << "EOF"
root:x:0:0:root:/home/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/bash
bin:x:2:2:bin:/bin:/bin/bash
sys:x:3:3:sys:/dev:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/bin/bash
ldeng:x:1000:1000:Linux User,,,:/home/ldeng:/bin/bash
EOF

cat > $1/target/rootfs/etc/group  << "EOF"
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
sudo:x:27:ldeng
users:x:100:
nogroup:x:65534:
ldeng:x:1000:
EOF

cat > $1/target/rootfs/home/root/.bashrc << "EOF"
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export PATH LD_LIBRARY_PATH
alias ll='ls -lt'
EOF

cat > $1/target/rootfs/home/ldeng/.bashrc << "EOF"
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export PATH LD_LIBRARY_PATH
alias ll='ls -lt'
EOF

cat > $1/target/rootfs/etc/busybox.conf << "EOF"
[SUID]
su = ssx 0.0 # run with euid=0/egid=0
id = ssx 0.0 # run with euid=0/egid=0
halt = ssx 0.0 # run with euid=0/egid=0
reboot = ssx 0.0 # run with euid=0/egid=0
shutdown= ssx 0.0 # run with euid=0/egid=0
passwd = --- 0.0 # disabled for all user except for root
EOF

cat > $1/target/rootfs/etc/sudoers << "EOF"
#
# This file MUST be edited with the 'visudo' command as root.
#
# See the sudoers man page for the details on how to write a sudoers file.
#

##
# Override built-in defaults
##
Defaults                syslog=auth,runcwd=~
Defaults>root           !set_logname
Defaults:FULLTIMERS     !lecture,runchroot=*
Defaults:millert        !authenticate
Defaults@SERVERS        log_year, logfile=/var/log/sudo.log
Defaults!PAGERS         noexec

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root    ALL=(ALL:ALL) ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
EOF

cat > $1/target/rootfs/etc/hostname << "EOF"
QEMU-QUARD-STAR
EOF

cat > $1/target/rootfs/etc/hosts << "EOF"
127.0.0.1 localhost
EOF

#build app and install
cd $1/app
./build.sh build $1/target/rootfs
cd -

#cp timezone info
sync

umount $1/target/bootfs
umount $1/target/rootfs
losetup -d /dev/loop70
sync
