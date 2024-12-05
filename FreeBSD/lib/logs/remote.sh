_bsd_fetch_remote_logs() {
	_BSD_TMP_LOG_DIR=$(mktemp -d)
	_defer _cleanup_remote_logs
	ssh root@$_BSD_REMOTE_HOST ls /var/log/walterjwhite >/dev/null 2>&1 || {
		_BSD_REMOTE_PREFIX=/mnt

		ssh root@$_BSD_REMOTE_HOST ls $_BSD_REMOTE_PREFIX/var/log/walterjwhite >/dev/null 2>&1 || _error "Unable to determine location of log files on $_BSD_REMOTE_HOST"
	}

	scp -r root@$_BSD_REMOTE_HOST:$_BSD_REMOTE_PREFIX/var/log/walterjwhite $_BSD_TMP_LOG_DIR
	mv $_BSD_TMP_LOG_DIR/walterjwhite $_BSD_TMP_LOG_DIR/host

	_info "Handling jails"

	mkdir -p $_BSD_TMP_LOG_DIR/jails

	_BSD_JAIL_REMOTE_PATH=$(ssh root@$_BSD_REMOTE_HOST mount | awk {'print$3'} | grep jails$)

	for _BSD_JAIL_PATH in $(ssh root@$_BSD_REMOTE_HOST find $_BSD_JAIL_REMOTE_PATH -type d -maxdepth 1 ! -name 'jails'); do
		_BSD_JAIL_NAME=$(basename $_BSD_JAIL_PATH)
		_detail "Copying jail ($_BSD_JAIL_NAME)"

		scp -r root@$_BSD_REMOTE_HOST:${_BSD_JAIL_PATH}/var/log/walterjwhite $_BSD_TMP_LOG_DIR/jails/$_BSD_JAIL_NAME
		_HAS_JAILS=1
	done
}

_bsd_read_remote_logs_completed() {
	_bsd_fetch_remote_logs $1

	_bsd_read_logs $_BSD_TMP_LOG_DIR/host
	[ $_HAS_JAILS ] && {
		for _BSD_JAIL_PATH in $(find $_BSD_TMP_LOG_DIR/jails -type d -maxdepth 1 ! -name jails); do
			_BSD_JAIL_NAME=$(basename $_BSD_JAIL_PATH)
			_detail "Reading jail ($_BSD_JAIL_NAME)"

			_bsd_read_logs $_BSD_JAIL_PATH
		done
	}
}

_bsd_read_remote_logs_in_progress() {
	ssh root@$_BSD_REMOTE_HOST ls /var/log/walterjwhite 2>/dev/null || _BSD_PREFIX=/mnt
	ssh root@$_BSD_REMOTE_HOST tail -f "$_BSD_PREFIX/var/log/walterjwhite/*"
}

_bsd_read_remote_logs() {
	_BSD_REMOTE_HOST=$1
	shift

	ssh root@$_BSD_REMOTE_HOST ps aux | grep bsdinstall | grep -v grep && _bsd_read_remote_logs_in_progress || _bsd_read_remote_logs_completed
}

_cleanup_remote_logs() {
	rm -rf $_BSD_TMP_LOG_DIR
}
