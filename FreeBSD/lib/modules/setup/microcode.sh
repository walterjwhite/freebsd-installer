import git:install/install/pkg.sh
import git:install/time.sh

_microcode_jail=0

_microcode() {
	_pkg_install $_CONF_FREEBSD_INSTALLER_REQUIRED_MICROCODE_PACKAGES || {
		_error "Error installing $_CONF_FREEBSD_INSTALLER_REQUIRED_MICROCODE_PACKAGES"
		return 1
	}

	_enable_cpu_microcode_patches
	_patch_microcode
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
