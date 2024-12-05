_net() {
	ifconfig $_CONF_FREEBSD_INSTALLER_NET up

	killall dhclient 2>/dev/null

	dhclient $_CONF_FREEBSD_INSTALLER_NET >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		_error "Unable to bring up $_CONF_FREEBSD_INSTALLER_NET"
	fi
}

_determine_network_interface() {
	[ -n "$_CONF_FREEBSD_INSTALLER_NET" ] && return

	_CONF_FREEBSD_INSTALLER_NET=$(ifconfig -l | tr ' ' '\n' | grep -v ^lo | grep -v ^pf)

}
