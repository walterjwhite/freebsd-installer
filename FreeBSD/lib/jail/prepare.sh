import bsdinstall/ssh-package-cache.sh

_jail_prepare() {
	_PRE_JAIL_PWD=$PWD

	. $_JAIL_PATH/.jail

	if [ -z "$_JAIL_ID" ]; then
		_JAIL_ID=10
	else
		_JAIL_ID=$(($_JAIL_ID + 1))
	fi


	sed -e "s/_JAIL_ZFS_MOUNTPOINT/$_JAIL_ZFS_MOUNTPOINT_SED_SAFE/" $_JAIL_PATH/jail.conf >>/etc/jail.conf.d/${_JAIL_NAME}.conf
	$_CONF_INSTALL_GNU_SED -i "s/_GUEST_IP_/$_CONF_FREEBSD_INSTALLER_JAIL_GUEST_IP/" /etc/jail.conf.d/${_JAIL_NAME}.conf
	$_CONF_INSTALL_GNU_SED -i "s/_JAIL_SUBNET_/$_CONF_FREEBSD_INSTALLER_JAIL_SUBNET/" /etc/jail.conf.d/${_JAIL_NAME}.conf
	$_CONF_INSTALL_GNU_SED -i "s/_DEVFS_RULESET_/$_JAIL_ID/" /etc/jail.conf.d/${_JAIL_NAME}.conf

	if [ -e $_JAIL_PATH/devfs.rules ]; then
		printf '[jail_%s=%s]\n' "$_JAIL_NAME" "$_JAIL_ID" >>/etc/devfs.rules
		cat $_JAIL_PATH/devfs.rules >>/etc/devfs.rules

		printf '\n\n' >>/etc/devfs.rules
	fi

	zfs list $_JAIL_ZFS_DATASET/$_JAIL_NAME >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		_info "Creating ZFS dataset $_JAIL_ZFS_DATASET/$_JAIL_NAME"
		zfs create $_JAIL_ZFS_DATASET/$_JAIL_NAME
	fi

	_info "Setting up base system in jail"
	tar -xkf $_JAIL_ZFS_MOUNTPOINT/base.txz -C $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME

	_info "Setting up DNS in jail"
	printf 'nameserver %s\n' "$_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP" >$_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/etc/resolv.conf

	cp -R /root/.ssh $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/tmp/HOST-SSH

	_jail_install_sshfs && _setup_ssh_package_cache $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME
	_jail_mount_procfs

	_jail_install_app install

	_NO_COPY_CONF=1 _jail_install_app freebsd-installer

	_update_jails

	service jail start $_JAIL_NAME
}

_jail_install_sshfs() {
	_pkg_install fusefs-sshfs
}

_jail_mount_procfs() {
	_info "Mounting procfs @ $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/proc"
	mkdir -p $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/proc
	mount -t procfs proc $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/proc || {
		_warn "Error mounting procfs @ $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/proc"
		return 1
	}

	_defer _jail_umount_procfs
}

_jail_install_app() {
	_info "Installing $1 in jail"
	mkdir -p /$_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root/.config/walterjwhite

	if [ -z "$_NO_COPY_CONF" ]; then
		cp ~/.config/walterjwhite/$1 /$_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root/.config/walterjwhite
	fi

	_ROOT=/$_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME app-install $1
}

_update_jails() {
	local jails=$(sysrc -f /etc/rc.conf -e jail_list | cut -f2 -d'=' | tr -d '"')
	if [ -n "$jails" ]; then
		jails="$jails $_JAIL_NAME"
	else
		jails="$_JAIL_NAME"
	fi

	sysrc -f /etc/rc.conf jail_list="$jails"
}
