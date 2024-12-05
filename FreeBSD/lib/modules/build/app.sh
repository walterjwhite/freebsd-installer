_app_is_file=1

_app() {
	local app
	for app in $@; do
		app-install $app
	done
}
