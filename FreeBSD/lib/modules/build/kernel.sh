import git:install/file.sh

_kernel_jail=0

_kernel() {

	_SYSTEM_VERSION=$(uname -r | sed -e "s/\-.*//")
	_SYSTEM_ARCHITECTURE=$(uname -m)

	local kernel_patch_path=$(dirname $1)
	_require_file "$kernel_patch_path"

	[ -e $kernel_patch_path/make.conf ] && cp $kernel_patch_path/make.conf /etc

	if [ $(grep -c cpuctl /etc/make.conf) -eq 0 ]; then
		_warn "Enabling CPU microcode update support by including cpuctl as a kernel module"
		$_CONF_INSTALL_GNU_SED -i 's/MODULES_OVERRIDE=/MODULES_OVERRIDE=cpuctl /' /etc/make.conf
	fi

	local system_configuration=/usr/src/sys/$_SYSTEM_ARCHITECTURE/conf
	if [ ! -e $system_configuration ]; then
		git clone -b releng/$_SYSTEM_VERSION --depth 1 https://git.freebsd.org/src.git /usr/src
		cp $kernel_patch_path/kernel $system_configuration/custom
	fi

	cd /usr/src

	_info "Building $_SYSTEM_ARCHITECTURE kernel"

	kernel_out=$(mktemp)
	kernel_error=$(mktemp)
	KERNCONF=custom make buildkernel >$kernel_out 2>$kernel_error || {
		_kernel_output Build
		return 1
	}

	KERNCONF=custom make installkernel >$kernel_out 2>$kernel_error || {
		_kernel_output Install
		return 2
	}

	_kernel_output

	$_CONF_INSTALL_GNU_SED -i "s/Components src world kernel/Components src world/" /etc/freebsd-update.conf

	_info "kernel build complete"
}

_kernel_output() {
	if [ $# -gt 0 ]; then
		_warn "$1 kernel failed"
		cat $kernel_out $kernel_error
	fi

	rm -f $kernel_out $kernel_error

	unset kernel_out kernel_error
}
