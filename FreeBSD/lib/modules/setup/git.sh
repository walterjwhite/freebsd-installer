import git:install/ssh.sh

_git() {
	[ -n "$_IN_JAIL" ] && {
		_HOST_IP=$_CONF_FREEBSD_INSTALLER_JAIL_HOST_IP
		_SSH_HOST_PORT=$_CONF_FREEBSD_INSTALLER_JAIL_SSH_HOST_PORT
		_PACKAGE_CACHE=$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE
		_GIT_MIRROR=$_CONF_FREEBSD_INSTALLER_GIT_MIRROR
	}

	_prepare_ssh_conf $HOME $USER

	_prepare_etc_hosts

	git clone $_CONF_FREEBSD_INSTALLER_SYSTEM_GIT -b $_CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH $_SYSTEM_REPOSITORY_PATH || _error "Error cloning $_CONF_FREEBSD_INSTALLER_SYSTEM_GIT"

	cd $_SYSTEM_REPOSITORY_PATH

	git branch --no-color --show-current >$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	git log --pretty=medium --no-color -1 >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION

	printf 'Configuration Date: %s\n' "$(date)" >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	printf 'Node: %s\n' "$(uuidgen)" >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION

	_SYSTEM_HASH=$(git rev-parse HEAD)
}

_prepare_etc_hosts() {
	if [ "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" = "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" ]; then
		printf '%s git freebsd-package-cache\n' "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" >>/etc/hosts
	else
		printf '%s git\n' "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" >>/etc/hosts
		printf '%s freebsd-package-cache\n' "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" >>/etc/hosts
	fi
}
