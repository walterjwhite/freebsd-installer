_link() {
	local link_conf
	for link_conf in $@; do
		_link_do $link_conf
	done
}

_link_do() {
	. $1

	for _TARGET in $targets; do
		_detail "ln -sf $path -> $_TARGET"

		local parent=$(dirname $_TARGET)
		if [ ! -e $path ]; then
			_warn "$path does NOT exist"
			continue
		elif [ ! -e $parent ]; then
			mkdir -p $parent
		fi

		ln -sf $path $_TARGET
	done

	unset _TARGET path targets
}
