import git:install/install/freebsd-update.sh

_jail_setup() {
	_info "Running jail setup"

	_jail_do_setup pre

	unset SHELL

	_info "Bootstrapping Jail"

	freebsd_root=$_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME _freebsd_update

	mkdir -p $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/$_CONF_FREEBSD_INSTALLER_LOG_DIRECTORY

	unset _INDEX

	_environment_dump


	_LOG_INDENT="" _IN_JAIL=1 _CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH=$_JAIL_BRANCH jexec $_JAIL_NAME $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME/bin/bootstrap

	service jail stop $_JAIL_NAME

	cd $_PRE_JAIL_PWD
	_jail_do_setup post

	_jail_disable_bastion_host
}

_jail_do_setup() {
	local setup_path=$_JAIL_PATH/$1-setup
	if [ -e $setup_path ]; then
		_info "Running $setup_path"
		find $setup_path -type f -exec {} \;
	else
		_warn "$setup_path does not exist: $PWD"
	fi
}

_jail_disable_bastion_host() {
	_info "Disabling bastion host"

	find $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $_CONF_INSTALL_GNU_SED -i 's/^Host/# Host/' {} +
	find $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $_CONF_INSTALL_GNU_SED -i 's/^ Hostname/# Hostname/' {} +
	find $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $_CONF_INSTALL_GNU_SED -i 's/^ ProxyJump/# ProxyJump/' {} +

	find $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/root $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $_CONF_INSTALL_GNU_SED -i 's/^ User/# User/' {} +
}
