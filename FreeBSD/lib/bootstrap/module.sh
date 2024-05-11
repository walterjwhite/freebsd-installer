import modules

_module_run_modules() {
	local phase=$1
	shift

	local module
	for module in $@; do
		local module_name=$(basename $module)

		_set_logfile "$_CONF_FREEBSD_INSTALLER_LOG_DIRECTORY/${_INDEX}.${phase}.${module}"
		_reset_indent

		_INDEX=$((_INDEX + 1))

		cd $_SYSTEM_REPOSITORY_PATH

		_module_is_runnable || {
			_warn "$module_name is disabled in jail"
			continue
		}

		_module_run_${phase} $module_name
	done
}

_module_is_runnable() {
	[ -n "$_IN_JAIL" ] && _variable_is_set _${module_name}_jail && return 1

	return 0
}

_module_log_status() {
	local module_status=success
	local level=info
	if [ $1 -gt 0 ]; then
		module_status="error ($1)"
		level=warn
	fi

	_$level "end - $module_status"
}

_module_get_patch_name() {
	_module_get_patch_path "$1" |
		sed -e "s/^\.\///" -e "s/\.patch$//" -e "s/^patches\///"
}

_module_get_patch_path() {
	printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Po '^.*.\.patch'
}

[ -z "$_INDEX" ] && _INDEX=0
