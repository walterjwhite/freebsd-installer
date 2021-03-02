#!/bin/sh

_cleanup() {
	if [ -n "$_SYSTEM_REPOSITORY_PATH" ]; then
		rm -rf $_SYSTEM_REPOSITORY_PATH
	fi
}

trap _cleanup INT

for _ARG in $@; do
	case $_ARG in
	-b=*)
		_BRANCH="${_ARG#*=}"
		;;
	*)
		_SYSTEM_REPOSITORY_PATH=$(mktemp -d)

		# bypass the host checking (to avoid timeouts)
		#ssh -o "StrictHostKeyChecking no" $(echo $_ARG | sed -e "s/\:.*//")
		#exit
		mkdir -p ~/.ssh
		echo "StrictHostKeyChecking no" >>~/.ssh/config

		git clone $_ARG $_SYSTEM_REPOSITORY_PATH

		cd $_SYSTEM_REPOSITORY_PATH
		;;
	esac
done

if [ -z "$_SYSTEM_REPOSITORY_PATH" ]; then
	exitWithError "no git repository URL was specified" 1
fi

if [ -n "$_BRANCH" ]; then
	git checkout $_BRANCH
fi
