#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys
[ -d /proc/bus/usb ] && mount -t usbfs usbfs /proc/bus/usb

size_etc="6M"

if [ "$1" == "512" ] ; then
	size_tmp="40M"
	size_var="5M"
	tcp_rmem='20480 87380 8388608'
	tcp_wmem='20480 87380 8388608'
	tcp_mem='32768 65536 98304'
elif [ "$1" == "256" ] ; then
	size_tmp="32M"
	size_var="4M"
	tcp_rmem='16384 87380 4194304'
	tcp_wmem='16384 87380 4194304'
	tcp_mem='16384 32768 49152'
elif [ "$1" == "128" ] ; then
	size_tmp="24M"
	size_var="3M"
	tcp_rmem='12288 87380 2097152'
	tcp_wmem='12288 87380 2097152'
	tcp_mem='8192 16384 24576'
elif [ "$1" == "64" ] ; then
	size_tmp="16M"
	size_var="2M"
	tcp_rmem='8192 87380 1048576'
	tcp_wmem='8192 87380 1048576'
	tcp_mem='4096 8192 12288'
elif [ "$1" == "-l" ] ; then
	size_tmp="8M"
	size_var="1M"
	tcp_rmem='4096 87380 524288'
	tcp_wmem='4096 87380 524288'
	tcp_mem='2048 4096 6144'
fi

mount -t tmpfs tmpfs /dev   -o size=8K
mount -t tmpfs tmpfs /etc   -o size=$size_etc,noatime
mount -t tmpfs tmpfs /home  -o size=1M
mount -t tmpfs tmpfs /media -o size=8K
mount -t tmpfs tmpfs /mnt   -o size=8K
mount -t tmpfs tmpfs /tmp   -o size=$size_tmp
mount -t tmpfs tmpfs /var   -o size=$size_var

mkdir /dev/pts
mount -t devpts devpts /dev/pts

mount -t debugfs debugfs /sys/kernel/debug

ln -sf /etc_ro/mdev.conf /etc/mdev.conf
mdev -s

# create dirs
mkdir -p -m 777 /var/lock
mkdir -p -m 777 /var/locks
mkdir -p -m 777 /var/private
mkdir -p -m 700 /var/empty
mkdir -p -m 777 /var/lib
mkdir -p -m 777 /var/log
mkdir -p -m 777 /var/run
mkdir -p -m 777 /var/tmp
mkdir -p -m 777 /var/spool
mkdir -p -m 777 /var/lib/misc
mkdir -p -m 777 /var/state
mkdir -p -m 777 /var/state/parport
mkdir -p -m 777 /var/state/parport/svr_statue
mkdir -p -m 777 /tmp/var
mkdir -p -m 777 /tmp/hashes
mkdir -p -m 777 /tmp/modem
mkdir -p -m 777 /tmp/rc_notification
mkdir -p -m 777 /tmp/rc_action_incomplete
mkdir -p -m 700 /home/root
mkdir -p -m 700 /home/root/.ssh
mkdir -p -m 755 /etc/storage
mkdir -p -m 755 /etc/ssl
mkdir -p -m 755 /etc/Wireless
mkdir -p -m 750 /etc/Wireless/RT2860
mkdir -p -m 750 /etc/Wireless/iNIC

# extract storage files
mtd_storage.sh load

touch /etc/resolv.conf

if [ -f /etc_ro/openssl.cnf ]; then
	cp -f /etc_ro/openssl.cnf /etc/ssl
fi

# create symlinks
ln -sf /home/root /home/admin
ln -sf /proc/mounts /etc/mtab
ln -sf /etc_ro/ethertypes /etc/ethertypes
ln -sf /etc_ro/protocols /etc/protocols
ln -sf /etc_ro/services /etc/services
ln -sf /etc_ro/shells /etc/shells
ln -sf /etc_ro/profile /etc/profile
ln -sf /etc_ro/e2fsck.conf /etc/e2fsck.conf
ln -sf /etc_ro/ipkg.conf /etc/ipkg.conf

# tune linux kernel
echo 65536 > /proc/sys/fs/file-max
echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
echo "$tcp_rmem" > /proc/sys/net/ipv4/tcp_rmem
echo "$tcp_wmem" > /proc/sys/net/ipv4/tcp_wmem
echo "$tcp_mem" > /proc/sys/net/ipv4/tcp_mem
echo 65535 > /proc/sys/net/ipv4/udp_rmem_min
echo 65535 > /proc/sys/net/ipv4/udp_wmem_min
echo 2048 4096 6144 > /proc/sys/net/ipv4/udp_mem

# fill storage
mtd_storage.sh fill

# prepare ssh authorized_keys
if [ -f /etc/storage/authorized_keys ] ; then
	cp -f /etc/storage/authorized_keys /home/root/.ssh
	chmod 600 /home/root/.ssh/authorized_keys
fi

# setup htop default color
if [ -f /usr/bin/htop ]; then
	mkdir -p /home/root/.config/htop
	echo "color_scheme=6" > /home/root/.config/htop/htoprc
fi

# perform start script
if [ -x /etc/storage/start_script.sh ] ; then
	/etc/storage/start_script.sh
fi
