_cleanup_prior_installation() {
	_cleanup_is_mounted || return 1

	_info "Cleaning up previous installation ..."
	umount $(mount | grep /mnt | awk {'print$1'}) >/dev/null 2>&1

	zpool export $ZFSBOOT_POOL_NAME
	geli detach $(find /dev -name "*${_CONF_FREEBSD_INSTALLER_DEV}*.eli") >/dev/null 2>&1
}

_cleanup_is_mounted() {
	mount | grep -c /mnt >/dev/null 2>&1
}
