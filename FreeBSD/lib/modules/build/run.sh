_run() {
	local run_conf
	for run_conf in $@; do
		cd $_SYSTEM_REPOSITORY_PATH

		. $run_conf
	done
}
