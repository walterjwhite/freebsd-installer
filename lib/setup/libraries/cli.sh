#!/bin/sh

_cleanup() {
  if [ -n "$_SYSTEM_REPOSITORY_PATH" ]
  then
    rm -rf $_SYSTEM_REPOSITORY_PATH
  fi
}

trap _cleanup INT

for _ARG in $@
do
  case $_ARG in
    -u)
      _is_default=$(beadm list | grep N | grep -c ^default)
      if [ "$_is_default" -eq "0" ]
      then
        _ beadm activate default
        _ reboot
      else
        echo "default BE is already activated, continuiing"
      fi

      ;;
    -b=*)
      _BRANCH="${_ARG#*=}"
      ;;
    *)
      _SYSTEM_REPOSITORY_PATH=$(mktemp -d)
      git clone $_ARG $_SYSTEM_REPOSITORY_PATH

      cd $_SYSTEM_REPOSITORY_PATH
      ;;
  esac
done

if [ -z "$_SYSTEM_REPOSITORY_PATH" ]
then
  exitWithError "no git repository URL was specified" 1
fi

if [ -n "$_BRANCH" ]
then
  git checkout $_BRANCH
fi