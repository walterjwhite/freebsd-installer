_cleanup_prior_installation() {
	_cleanup_is_mounted || return 1

	_info "Cleaning up previous installation ..."
	umount $(mount | grep /mnt | awk {'print$1'}) >/dev/null 2>&1

	zpool list -H | awk {'print$1'} | while read _ZFS_POOL; do
		zpool export $_ZFS_POOL
	done

	find /dev -name "*.eli" -type c -depth 1 2>/dev/null | while read _GELI_DEVICE; do
		geli detach $_GELI_DEVICE
	done
}

_cleanup_is_mounted() {
	mount | grep -c /mnt >/dev/null 2>&1
}
