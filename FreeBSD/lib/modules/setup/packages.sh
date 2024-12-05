import git:install/install/pkg.sh
import git:install/time.sh

_packages() {
	local packages=$_CONF_FREEBSD_INSTALLER_REQUIRED_PACKAGES
	if [ -z "$_IN_JAIL" ]; then
		packages="$_CONF_FREEBSD_INSTALLER_REQUIRED_BASE_PACKAGES $packages"
	fi

	_pkg_install $packages || {
		_error "Error installing $packages"
		return 1
	}

	_info "Installed: $packages"
}
