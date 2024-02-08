import git:install/install/pkg.sh
import git:install/time.sh

_packages() {
	local packages=$_CONF_FREEBSD_INSTALLER_REQUIRED_PACKAGES
	if [ -z "$_IN_JAIL" ]; then
		_pkg_setup_ssh_package_cache $_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE
		packages="$_CONF_FREEBSD_INSTALLER_REQUIRED_BASE_PACKAGES $packages"
		_enable_cpu_microcode_patches
	fi

	_pkg_install $packages || {
		_error "Error installing $packages"
		return 1
	}

	_info "Installed: $packages"
	if [ -z "$_IN_JAIL" ]; then
		_patch_microcode
	fi
}

_enable_cpu_microcode_patches() {
	local cpu_vendor=intel
	if [ $(sysctl -a | egrep -i 'hw.model' | grep -ic amd) -gt 0 ]; then
		cpu_vendor=amd
	fi

	printf 'microcode_update_enable="YES"\n' >>/etc/rc.conf
	printf 'cpu_microcode_load="YES"\n' >>/boot/loader.conf
	printf 'cpu_microcode_name="/boot/firmware/%s-ucode.bin"\n' "$cpu_vendor" >>/boot/loader.conf
	_info "installed support for patching CPU microcode ($cpu_vendor)"
}

_patch_microcode() {
	_warn "Patching CPU microcode"
	service microcode_update start
}
