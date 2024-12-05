_geli_jail=0

_geli() {
	[ -z "$_CONF_FREEBSD_INSTALLER_GELI_GIT" ] && {
		_warn "_CONF_FREEBSD_INSTALLER_GELI_GIT is not configured, not backing up GELI metadata - $geli_device_file"
		return 1
	}

	local geli_device=${_CONF_FREEBSD_INSTALLER_DEV}p3.eli
	local geli_device_file=/dev/$geli_device
	[ ! -e $geli_device_file ] && {
		_warn "Unable to backup GELI metadata - $geli_device_file"
		return 2
	}

	_info "Backing up GELI metadata - $geli_device_file"

	local geli_workspace=$(mktemp -d)

	git clone $_CONF_FREEBSD_INSTALLER_GELI_GIT $geli_workspace
	if [ $? -eq 0 ]; then
		cd $geli_workspace

		local geli_device_arg=${_CONF_FREEBSD_INSTALLER_DEV}p3
		geli backup $geli_device_arg $ZFSBOOT_POOL_NAME

		git config --global user.email "$(whoami)@$(hostname)"
		git config --global user.name "$(whoami)@$(hostname)"

		git add $ZFSBOOT_POOL_NAME
		git commit $ZFSBOOT_POOL_NAME -m "$ZFSBOOT_POOL_NAME - $_CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH -  $(date)"
		git push
	else
		_warn "Unable to backup GELI metadata - $geli_device_file - error cloning $_CONF_FREEBSD_INSTALLER_GELI_GIT"
	fi

	cd /tmp
	rm -rf $geli_workspace
}
