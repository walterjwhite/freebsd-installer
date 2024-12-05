_module_run_build() {
	local module_name=$1

	local module_exec=$(env | grep ^_${module_name}_exec= | sed -e "s/^_${module_name}_exec=//")
	local module_type=$(env | grep ^_${module_name}_type= | sed -e "s/^_${module_name}_type=//")
	local module_options=$(env | grep ^_${module_name}_options= | sed -e "s/^_${module_name}_options=//")
	local module_is_file=$(env | grep ^_${module_name}_is_file= | sed -e "s/^_${module_name}_is_file=//")

	local module_path=$(env | grep ^_${module_name}_path= | sed -e "s/^_${module_name}_path=//")

	[ -z "$module_type" ] && module_type=f
	[ -z "$module_path" ] && module_path="$1/*"
	[ $module_is_file ] && module_path=$module_name

	if [ $(_module_find $module_type $module_path $module_options -print -quit | wc -l) -eq 0 ]; then
		_info "no patches found"
		return 1
	fi

	_info "start"

	_call _${module_name}_pre

	local module_status
	if [ -n "$module_is_file" ]; then
		module_path=$module_name

		_$module_name $(_module_find $module_type $module_path $module_options -exec $_CONF_INSTALL_GNU_GREP -Pvh '(^#|^$)' {} + | tr '\n' ' ' | sed -e 's/ $/\n/')
		module_status=$?
	else
		if [ -z "$module_exec" ]; then
			_$module_name $(_module_find $module_type $module_path $module_options | sort)
			module_status=$?
		else
			_module_find $module_type $module_path $module_options -exec $module_exec
			module_status=$?
		fi
	fi

	_call _${module_name}_post

	_module_log_status $module_status
}

_module_find() {
	local module_type=$1
	shift
	local module_path=$1
	shift

	local patch_path=physical
	[ -n "$_IN_JAIL" ] && patch_path=jail

	[ -e patches/any ] && find -s patches/any -type $module_type -path "*/*.patch/$module_path" "$@" 2>/dev/null
	[ -e patches/$patch_path ] && find -s patches/$patch_path -type $module_type -path "*/*.patch/$module_path" "$@" 2>/dev/null

	return 0
}
