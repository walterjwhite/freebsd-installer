_ssh_keys() {
	_SSH_KEY=/root/.ssh/id_ecdsa

	ssh-keygen -R $_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE
}
