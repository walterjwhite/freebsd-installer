_setup_ssh_package_cache() {
	_PACKAGE_CACHE_MOUNT_DIR=$1

	_info "Mounting pkg cache @ $_PACKAGE_CACHE_MOUNT_DIR/var/cache/pkg"
	mkdir -p $_PACKAGE_CACHE_MOUNT_DIR/var/cache/pkg

	sshfs -o StrictHostKeyChecking=no $_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE:/var/cache/pkg $_PACKAGE_CACHE_MOUNT_DIR/var/cache/pkg || {
		_warn "Error mounting package cache "
		return 1
	}

	_defer _cleanup_ssh_package_cache
}

_cleanup_ssh_package_cache() {
	_info "Unmounting pkg cache"
	umount $_PACKAGE_CACHE_MOUNT_DIR/var/cache/pkg
}
