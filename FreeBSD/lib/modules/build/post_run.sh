_post_run() {
	local post_run_conf
	for post_run_conf in $@; do
		cd $_SYSTEM_REPOSITORY_PATH

		. $post_run_conf
	done
}
