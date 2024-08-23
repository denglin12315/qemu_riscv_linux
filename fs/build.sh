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
mkdir -p $1/target/rootfs/usr/local/etc
mkdir -p $1/target/rootfs/home/ldeng
mkdir -p $1/target/rootfs/home/root
mkdir -p $1/target/rootfs/usr/share/udhcpc
mkdir -p $1/target/rootfs/etc/network/if-pre-up.d
mkdir -p $1/target/rootfs/etc/network/if-up.d
mkdir -p $1/target/rootfs/etc/network/if-down.d
mkdir -p $1/target/rootfs/etc/network/if-post-down.d
mkdir -p $1/target/rootfs/var/run/

touch $1/target/rootfs/var/run/ifstate.new

cat >$1/target/rootfs/usr/local/etc/sshd_config << "EOF"
#	$OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.
# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin
# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
HostKey /usr/local/etc/ssh_host_rsa_key
HostKey /usr/local/etc/ssh_host_ecdsa_key
HostKey /usr/local/etc/ssh_host_ed25519_key
# Ciphers and keying
#RekeyLimit default none
# Logging
#SyslogFacility AUTH
#LogLevel INFO
# Authentication:
#LoginGraceTime 2m
#PermitRootLogin prohibit-password
PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10
#PubkeyAuthentication yes
# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys
#AuthorizedPrincipalsFile none
#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody
# For this to work you will also need host keys in /home/qqm/Downloads/quard_star_tutorial/target_root_app/output/etc/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes
# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no
# Change to no to disable s/key passwords
#ChallengeResponseAuthentication yes
# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
# GSSAPI options
GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
#UsePAM no
#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none
# no default banner path
#Banner none
# override default of no subsystems
Subsystem	sftp	/usr/local/libexec/sftp-server
# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
EOF

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

if [ ! -f /usr/local/bin/ssh ]; then
	cd /mnt/openssh-8.6p1
	make install
	cd -
fi

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


cat > $1/target/rootfs/etc/init.d/S90sshd.sh << "EOF"
#! /bin/bash
sshd=/usr/local/sbin/sshd
test -x "$sshd" || exit 0
case "$1" in
  start)
    echo -n "Starting sshd daemon"
    start-stop-daemon --start --quiet --exec $sshd  -b
    echo "."
    ;;
  stop)
    echo -n "Stopping sshd"
    start-stop-daemon --stop --quiet --exec $sshd
    echo "."
    ;;
  restart)
    echo -n "Stopping sshd"
    start-stop-daemon --stop --quiet --exec $sshd
    echo "."
    echo -n "Waiting for sshd to die off"
    for i in 1 2 3 ;
    do
        sleep 1
        echo -n "."
    done
    echo ""
    echo -n "Starting sshd daemon"
    start-stop-daemon --start --quiet --exec $sshd -b
    echo "."
    ;;
  *)
    echo "Usage: /etc/init.d/S90sshd.sh {start|stop|restart}"
    exit 1
esac
exit 0
EOF
chmod a+x $1/target/rootfs/etc/init.d/S90sshd.sh

cat > $1/target/rootfs/etc/init.d/S01syslogd << "EOF"
#!/bin/sh

DAEMON="syslogd"
PIDFILE="/var/run/$DAEMON.pid"

SYSLOGD_ARGS=""

# shellcheck source=/dev/null
[ -r "/etc/default/$DAEMON" ] && . "/etc/default/$DAEMON"

# BusyBox' syslogd does not create a pidfile, so pass "-n" in the command line
# and use "-m" to instruct start-stop-daemon to create one.
start() {
	printf 'Starting %s: ' "$DAEMON"
	# shellcheck disable=SC2086 # we need the word splitting
	start-stop-daemon -b -m -S -q -p "$PIDFILE" -x "/sbin/$DAEMON" \
		-- -n $SYSLOGD_ARGS
	status=$?
	if [ "$status" -eq 0 ]; then
		echo "OK"
	else
		echo "FAIL"
	fi
	return "$status"
}

stop() {
	printf 'Stopping %s: ' "$DAEMON"
	start-stop-daemon -K -q -p "$PIDFILE"
	status=$?
	if [ "$status" -eq 0 ]; then
		rm -f "$PIDFILE"
		echo "OK"
	else
		echo "FAIL"
	fi
	return "$status"
}

restart() {
	stop
	sleep 1
	start
}

case "$1" in
	start|stop|restart)
		"$1";;
	reload)
		# Restart, since there is no true "reload" feature.
		restart;;
	*)
		echo "Usage: $0 {start|stop|restart|reload}"
		exit 1
esac
EOF
chmod a+x $1/target/rootfs/etc/init.d/S01syslogd


cat > $1/target/rootfs/etc/init.d/S02klogd << "EOF"
#!/bin/sh

DAEMON="klogd"
PIDFILE="/var/run/$DAEMON.pid"

KLOGD_ARGS=""

# shellcheck source=/dev/null
[ -r "/etc/default/$DAEMON" ] && . "/etc/default/$DAEMON"

# BusyBox' klogd does not create a pidfile, so pass "-n" in the command line
# and use "-m" to instruct start-stop-daemon to create one.
start() {
	printf 'Starting %s: ' "$DAEMON"
	# shellcheck disable=SC2086 # we need the word splitting
	start-stop-daemon -b -m -S -q -p "$PIDFILE" -x "/sbin/$DAEMON" \
		-- -n $KLOGD_ARGS
	status=$?
	if [ "$status" -eq 0 ]; then
		echo "OK"
	else
		echo "FAIL"
	fi
	return "$status"
}

stop() {
	printf 'Stopping %s: ' "$DAEMON"
	start-stop-daemon -K -q -p "$PIDFILE"
	status=$?
	if [ "$status" -eq 0 ]; then
		rm -f "$PIDFILE"
		echo "OK"
	else
		echo "FAIL"
	fi
	return "$status"
}

restart() {
	stop
	sleep 1
	start
}

case "$1" in
	start|stop|restart)
		"$1";;
	reload)
		# Restart, since there is no true "reload" feature.
		restart;;
	*)
		echo "Usage: $0 {start|stop|restart|reload}"
		exit 1
esac
EOF
chmod a+x $1/target/rootfs/etc/init.d/S02klogd

cat > $1/target/rootfs/etc/init.d/S02sysctl << "EOF"
#!/bin/sh
#
# This script is used by busybox and procps-ng.
#
# With procps-ng, the "--system" option of sysctl also enables "--ignore", so
# errors are not reported via syslog. Use the run_logger function to mimic the
# --system behavior, still reporting errors via syslog. Users not interested
# on error reports can add "-e" to SYSCTL_ARGS.
#
# busybox does not have a "--system" option neither reports errors via syslog,
# so the scripting provides a consistent behavior between the implementations.
# Testing the busybox sysctl exit code is fruitless, as at the moment, since
# its exit status is zero even if errors happen. Hopefully this will be fixed
# in a future busybox version.

PROGRAM="sysctl"

SYSCTL_ARGS=""

# shellcheck source=/dev/null
[ -r "/etc/default/$PROGRAM" ] && . "/etc/default/$PROGRAM"

# Files are read from directories in the SYSCTL_SOURCES list, in the given
# order. A file may be used more than once, since there can be multiple
# symlinks to it. No attempt is made to prevent this.
SYSCTL_SOURCES="/etc/sysctl.d/ /usr/local/lib/sysctl.d/ /usr/lib/sysctl.d/ /lib/sysctl.d/ /etc/sysctl.conf"

# If the logger utility is available all messages are sent to syslog, except
# for the final status. The file redirections do the following:
#
# - stdout is redirected to syslog with facility.level "kern.info"
# - stderr is redirected to syslog with facility.level "kern.err"
# - file dscriptor 4 is used to pass the result to the "start" function.
#
run_logger() {
	# shellcheck disable=SC2086 # we need the word splitting
	find $SYSCTL_SOURCES -maxdepth 1 -name '*.conf' -print0 2> /dev/null | \
	xargs -0 -r -n 1 readlink -f | {
		prog_status="OK"
		while :; do
			read -r file || {
				echo "$prog_status" >&4
				break
			}
			echo "* Applying $file ..."
			/sbin/sysctl -p "$file" $SYSCTL_ARGS || prog_status="FAIL"
		done 2>&1 >&3 | /usr/bin/logger -t sysctl -p kern.err
	} 3>&1 | /usr/bin/logger -t sysctl -p kern.info
}

# If logger is not available all messages are sent to stdout/stderr.
run_std() {
	# shellcheck disable=SC2086 # we need the word splitting
	find $SYSCTL_SOURCES -maxdepth 1 -name '*.conf' -print0 2> /dev/null | \
	xargs -0 -r -n 1 readlink -f | {
		prog_status="OK"
		while :; do
			read -r file || {
				echo "$prog_status" >&4
				break
			}
			echo "* Applying $file ..."
			/sbin/sysctl -p "$file" $SYSCTL_ARGS || prog_status="FAIL"
		done
	}
}

if [ -x /usr/bin/logger ]; then
	run_program="run_logger"
else
	run_program="run_std"
fi

start() {
	printf '%s %s: ' "$1" "$PROGRAM"
	status=$("$run_program" 4>&1)
	echo "$status"
	if [ "$status" = "OK" ]; then
		return 0
	fi
	return 1
}

case "$1" in
	start)
		start "Running";;
	restart|reload)
		start "Rerunning";;
	stop)
		:;;
	*)
		echo "Usage: $0 {start|stop|restart|reload}"
		exit 1
esac
EOF
chmod a+x $1/target/rootfs/etc/init.d/S02sysctl

cat > $1/target/rootfs/etc/init.d/S20urandom << "EOF"
#! /bin/sh
#
# Preserve the random seed between reboots. See urandom(4).
#

# Quietly do nothing if /dev/urandom does not exist
[ -c /dev/urandom ] || exit 0

URANDOM_SEED="/var/lib/random-seed"

# shellcheck source=/dev/null
[ -r "/etc/default/urandom" ] && . "/etc/default/urandom"

if pool_bits=$(cat /proc/sys/kernel/random/poolsize 2> /dev/null); then
	pool_size=$((pool_bits/8))
else
	pool_size=512
fi

check_file_size() {
	[ -f "$URANDOM_SEED" ] || return 1
	# Try to read two blocks but exactly one will be read if the file has
	# the correct size.
	size=$(dd if="$URANDOM_SEED" bs="$pool_size" count=2 2> /dev/null | wc -c)
	test "$size" -eq "$pool_size"
}

init_rng() {
	if check_file_size; then
		printf 'Initializing random number generator: '
		dd if="$URANDOM_SEED" bs="$pool_size" of=/dev/urandom count=1 2> /dev/null
		status=$?
		if [ "$status" -eq 0 ]; then
			echo "OK"
		else
			echo "FAIL"
		fi
		return "$status"
	fi
}

save_random_seed() {
	printf 'Saving random seed: '
	if touch "$URANDOM_SEED" 2> /dev/null; then
		old_umask=$(umask)
		umask 077
		dd if=/dev/urandom of="$URANDOM_SEED" bs="$pool_size" count=1 2> /dev/null
		status=$?
		umask "$old_umask"
		if [ "$status" -eq 0 ]; then
			echo "OK"
		else
			echo "FAIL"
		fi
	else
		status=$?
		echo "SKIP (read-only file system detected)"
	fi
	return "$status"
}

case "$1" in
	start|restart|reload)
		# Carry a random seed from start-up to start-up
		# Load and then save the whole entropy pool
		init_rng && save_random_seed;;
	stop)
		# Carry a random seed from shut-down to start-up
		# Save the whole entropy pool
		save_random_seed;;
	*)
		echo "Usage: $0 {start|stop|restart|reload}"
		exit 1
esac
EOF
chmod a+x $1/target/rootfs/etc/init.d/S20urandom

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
cp bin/mkdir usr/bin/mkdir
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
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
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
