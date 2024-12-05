_chmod() {
	local chmod_file
	for chmod_file in $@; do
		. $chmod_file
		chmod $options $mode $path

		unset mode path options
	done
}
