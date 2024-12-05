_post_install() {
	_validate_install

	_warn "Installation completed, please reboot into your new system"
}

_validate_install() {
	local error_count=0
	for f in $(find /var/log/walterjwhite -type f); do
		grep -cqm 1 ' is disabled in jail' $f && continue
		grep -cqm 1 'end - success' $f && continue
		grep -cqm 1 'no patches found' $f && continue

		_warn "$f - $(grep -hm1 'end - ' $f)"
		error_count=$((error_count + 1))
	done

	if [ $$ -gt 0 ]; then
		_warn "$error_count were found"
	fi
}
