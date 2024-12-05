#!/bin/sh

_SYSTEM_REPOSITORY_PATH=$(mktemp -d)

_freebsd_install_cleanup() {
	if [ -n "$_SYSTEM_REPOSITORY_PATH" ]; then
		cd /tmp
		rm -rf $_SYSTEM_REPOSITORY_PATH
	fi

	[ -n "$_INSTALLATION_PATH" ] && rm -rf $_INSTALLATION_PATH
}

_defer _freebsd_install_cleanup
mkdir -p $_CONF_FREEBSD_INSTALLER_CONFIGURATION_DIRECTORY $_CONF_FREEBSD_INSTALLER_LOG_DIRECTORY $(dirname $_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION)
