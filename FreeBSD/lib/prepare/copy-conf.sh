_copy_conf() {
	_info "Copying $SUDO_USER conf"

	$_SUDO_CMD mkdir -p $_MOUNT_POINT/root/.config/walterjwhite
	$_SUDO_CMD cp /home/$SUDO_USER/.config/walterjwhite/* $_MOUNT_POINT/root/.config/walterjwhite ||
		$_SUDO_CMD cp /root/.config/walterjwhite/* $_MOUNT_POINT/root/.config/walterjwhite ||
		_warn 'No conf was copied, installation will fail, please ensure /root/.conf/walterjwhite/freebsd-installer AND install exist'
}
