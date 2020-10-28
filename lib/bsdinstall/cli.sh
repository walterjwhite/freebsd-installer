#!/bin/sh

_require "$NET" "NET is required (ie. msk0)" 1
ifconfig $NET 2>&1 > /dev/null
if [ "$?" -gt "0" ]
then
	exitWithError "$NET does not appear to exist" 2
fi

_require "$DEV" "DEV is required (ie. ada0)" 3
_require "$DEV_NAME" "DEV_NAME is required (ie. 250.5 - NOTE: device will automatically be prefixed with 'z_')" 4
_INCORRECT_PREFIX=$(echo $DEV_NAME | grep -c ^z_)
if [ "$_INCORRECT_PREFIX" -gt "0" ]
then
	DEV_NAME=$(echo $DEV_NAME | sed -e "s/^z_//")
fi

_require "$HOSTNAME" "HOSTNAME is required (ie. acer-router)" 5

_require "$GIT" "GIT is required (ie. github.com/walterjwhite/freebsd-base-install)" 6
_require "$BRANCH" "BRANCH is required (ie. workstation)" 7

