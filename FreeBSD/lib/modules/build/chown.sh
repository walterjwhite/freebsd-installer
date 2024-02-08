_chown() {
	local chown_file
	for chown_file in $@; do
		. $chown_file
		chown $options $owner:$group $path

		unset owner group path options
	done
}
