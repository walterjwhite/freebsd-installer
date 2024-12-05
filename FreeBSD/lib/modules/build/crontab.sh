import git:install/crontab.sh

_crontab_type=d

_crontab() {
	local crontabs_temp_path=$(mktemp -d)

	local crontab_file
	local crontab_user_file
	local crontab_user
	local crontabs_directory
	for crontabs_directory in $@; do
		crontab_user=$(basename $crontabs_directory)
		crontab_user_file=$crontabs_temp_path/$crontab_user


		local crontab_path
		for crontab_path in $(find -s $crontabs_directory -type f); do
			printf '# %s\n' "$crontab_path" >>$crontab_user_file
			cat $crontab_path >>$crontab_user_file
		done
	done

	for crontab_user_file in $(find -s $crontabs_temp_path -type f | sort -u); do
		crontab_user=$(basename $crontab_user_file)

		_info "Updating $crontab_user crontab"
		_crontab_append $crontab_user $crontab_user_file

		rm -f $crontab_user_file
	done

	unset user
}
