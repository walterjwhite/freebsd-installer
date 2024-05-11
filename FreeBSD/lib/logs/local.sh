import git:install/file.sh

_bsd_read_logs() {
	_require "$1" "_bsd_read_logs:Log Directory"
	_require_file "$1" "_bsd_read_logs:Log Directory"

	cd $1
	for log in $(ls | sort -g); do
		clear
		less $log
	done
}

_bsd_read_jail_logs() {
	_WARN=1 _require "$1" "_bsd_read_jail_logs:Jail Log Directory" || return 1
	_WARN=1 _require_file "$1" "_bsd_read_jail_logs:Jail Log Directory" || return 1

	for _BSD_JAIL_PATH in $(find $1 -type d -maxdepth 1 ! -name jails); do
		_BSD_JAIL_NAME=$(basename $_BSD_JAIL_PATH)
		_detail "Reading jail ($_BSD_JAIL_NAME)"

		_bsd_read_logs $_BSD_JAIL_PATH/var/log/walterjwhite
	done
}

_bsd_read_logs_locally() {
	if [ ! -e /var/log/walterjwhite ]; then
		if [ -e /mnt/var/log/walterjwhite ]; then
			_BSD_PREFIX=/mnt
		else
			_error "Unable to determine location of log files"
		fi
	fi

	if [ $(ps aux | grep bsdinstall | grep -v grep | wc -l) -gt 0 ]; then
		tail -f $_BSD_PREFIX/var/log/walterjwhite/*
	fi

	_bsd_read_logs $_BSD_PREFIX/var/log/walterjwhite

	_JAIL_VOLUME=$(zfs list -H | awk '{print$1}' | grep jails$)
	_JAIL_MOUNT_POINT=$_BSD_PREFIX/${_JAIL_VOLUME}

	[ $_JAIL_VOLUME ] && {
		[ ! -e $_JAIL_MOUNT_POINT ] && _JAIL_MOUNT_POINT=$(mount | awk {'print$3'} | grep jails$)

		_bsd_read_jail_logs $_JAIL_MOUNT_POINT
	}
}
