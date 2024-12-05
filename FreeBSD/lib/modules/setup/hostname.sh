_hostname() {
	if [ -n "$_JAIL_NAME" ]; then
		_FREEBSD_INSTALL_HOSTNAME=$_JAIL_NAME
	else
		_FREEBSD_INSTALL_HOSTNAME=$(_hostname_from_branch)-$(_hostname_from_serial_number)
	fi

	printf 'hostname=%s\n' "$_FREEBSD_INSTALL_HOSTNAME" >>/etc/rc.conf.local
}

_hostname_from_branch() {
	printf '%s' "$_CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH" | sed -e 's/^.*\///'
}

_hostname_from_serial_number() {
	dmidecode 2>/dev/null | grep 'Base Board Information' -A10 | grep 'Serial Number' | cut -f2 -d':' |
		sed -e 's/^ //' -e 's/\//./g' -e 's/^\.//' -e 's/\.$//'
}
