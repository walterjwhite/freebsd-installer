_install_ssh_keys() {
	_info "Copying $SUDO_USER ssh keys"

	mkdir -p $_MOUNT_POINT/root/.ssh
	cp /home/$SUDO_USER/.ssh/id_* $_MOUNT_POINT/root/.ssh
	cp /home/$SUDO_USER/.ssh/known_hosts $_MOUNT_POINT/root/.ssh

	cat /home/$SUDO_USER/.ssh/id*.pub >>$_MOUNT_POINT/root/.ssh/authorized_keys
}
