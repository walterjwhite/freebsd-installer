import git:install/install/pkg.sh
import git:install/sed.sh

_jail_jail=0

_jail_options='-name *.jail'
_jail_exec='jail-setup {} ;'


_jail_pre() {
	[ -e $ZFSBOOT_POOL_NAME/jails ] && return 1

	_jail_init
	_jail_init_networking
	_jail_init_ssh
	_jail_init_dns
	_jail_init_proxy

	_NON_INTERACTIVE=1
}

_jail_init() {
	_JAIL_ZFS_DATASET=$ZFSBOOT_POOL_NAME/jails

	zfs list $_JAIL_ZFS_DATASET >/dev/null 2>&1
	[ $? -gt 0 ] && zfs create $_JAIL_ZFS_DATASET

	_JAIL_ZFS_MOUNTPOINT=$(zfs list -H -o mountpoint $_JAIL_ZFS_DATASET)
	_JAIL_ZFS_MOUNTPOINT_SED_SAFE=$(_sed_safe $_JAIL_ZFS_MOUNTPOINT)

	rm -f /etc/jail.conf /etc/jail.conf.d/*

	sysrc -f /etc/rc.conf jail_enable=YES

	_ARCHITECTURE=$(sysctl -a | grep -i 'hw.machine_arch' | awk '{print$2}')
	_SYSTEM_VERSION=$(uname -r | sed -e "s/\-p.*//")
	if [ ! -e $_JAIL_ZFS_MOUNTPOINT/base.txz ]; then
		if [ ! -e /usr/freebsd-dist/base.txz ]; then
			fetch https://ftp.freebsd.org/pub/FreeBSD/releases/$_ARCHITECTURE/$_ARCHITECTURE/$_SYSTEM_VERSION/base.txz -o $_JAIL_ZFS_MOUNTPOINT/base.txz
		else
			cp /usr/freebsd-dist/base.txz $_JAIL_ZFS_MOUNTPOINT/base.txz
		fi
	fi

	_pkg_install unbound tinyproxy || _error "Error setting up jail proxy"
}

_jail_init_networking() {
	ifconfig lo1 create
	ifconfig lo1 $_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP netmask $_CONF_FREEBSD_INSTALLER_JAIL_SUBNET up
}

_jail_init_ssh() {
	printf 'Port %s\n' "$_CONF_FREEBSD_INSTALLER_JAIL_SSH_HOST_PORT" >>/etc/ssh/sshd_config

	service sshd onestart

	_debug "Appending SSH key to authorized keys"
	cat ~/.ssh/id_ecdsa.pub >>~/.ssh/authorized_keys

	chmod 600 ~/.ssh/authorized_keys
	mkdir -p ~/.ssh/socket
	chmod 700 ~/.ssh/socket
}

_jail_init_dns() {
	_UPSTREAM_DNS_SERVER=$(grep nameserver /etc/resolv.conf | cut -f2 -d ' ')

	printf 'server:\n' >/usr/local/etc/unbound/unbound.conf
	printf '\tinterface: %s\n' "$_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP" >>/usr/local/etc/unbound/unbound.conf
	printf '\taccess-control: %s allow\n' $_CONF_FREEBSD_INSTALLER_JAIL_ACCESS_NETWORK >>/usr/local/etc/unbound/unbound.conf
	printf 'forward-zone:\n' >>/usr/local/etc/unbound/unbound.conf
	printf '\tname: "."\n' >>/usr/local/etc/unbound/unbound.conf
	printf '\tforward-addr: %s\n' "$_UPSTREAM_DNS_SERVER" >>/usr/local/etc/unbound/unbound.conf

	_warn "Using $_UPSTREAM_DNS_SERVER as the upstream DNS server"

	service unbound onestart
}

_jail_init_proxy() {
	printf 'Allow %s\n' $_CONF_FREEBSD_INSTALLER_JAIL_ACCESS_NETWORK >>/usr/local/etc/tinyproxy.conf
	printf 'upstream none "."\n' >>/usr/local/etc/tinyproxy.conf

	service tinyproxy onestart

	http_proxy=$_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP:$_CONF_FREEBSD_INSTALLER_JAIL_PROXY_PORT
	https_proxy=$_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP:$_CONF_FREEBSD_INSTALLER_JAIL_PROXY_PORT
}

_jail_post() {
	_jail_restore_ssh

	service sshd onestop
	service tinyproxy onestop
	service unbound onestop

	_pkg_uninstall unbound tinyproxy

	rm -rf /usr/local/etc/unbound
	rm -rf /usr/local/etc/tinyproxy.conf
	rm -f /var/log/tinyproxy.log

	rmuser -y unbound

	$_CONF_INSTALL_GNU_SED -i 's/^Port/# Port/' /etc/ssh/sshd_config

	unset _JAIL_ZFS_DATASET _JAIL_ZFS_MOUNTPOINT _JAIL_ZFS_MOUNTPOINT_SED_SAFE
}

_jail_restore_ssh() {
	[ -e $_JAIL_ZFS_MOUNTPOINT/root/.ssh.restore ] && _jail_restore_ssh_do $_JAIL_ZFS_MOUNTPOINT/root

	for s in $(find $_JAIL_ZFS_MOUNTPOINT/home -type d -depth 2 -name '.ssh.restore'); do
		_jail_restore_ssh_do $(dirname $s)
	done
}

_jail_restore_ssh_do() {
	rm -rf $1/.ssh
	mv $1/.ssh.restore $1/.ssh
}
