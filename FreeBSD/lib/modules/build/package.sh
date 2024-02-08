import git:install/install/pkg.sh

_package_is_file=1
_package() {
	[ $# -eq 0 ] && _error 'No packages'

	_CONF_INSTALL_STEP_TIMEOUT=$_CONF_FREEBSD_INSTALLER_PACKAGE_TIMEOUT _pkg_install "$@"
}
