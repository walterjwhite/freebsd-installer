import git:install/install/module/user.sh

_user() {
	_user_bootstrap

	local user_conf
	for user_conf in $@; do
		_users_add $user_conf

		unset _CONFIGURATION_INSTALLED
	done
}
