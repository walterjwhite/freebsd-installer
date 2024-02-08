_cleanup_prior_installation() {
	mount | grep -c mnt >/dev/null 2>&1 && {
		_info "Cleaning up previous installation ..."
		umount $(mount | grep mnt) >/dev/null 2>&1

		geli detach $(find /dev -name "*${_CONF_FREEBSD_INSTALLER_DEV}*.eli") >/dev/null 2>&1
	}
}
