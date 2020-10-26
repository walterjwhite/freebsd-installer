#!/bin/sh

if [ -z "$NET" ]
then
	exitWithError "NET is required (ie. msk0)" 1
else
	ifconfig $NET 2>&1 > /dev/null
	if [ "$?" -gt "0" ]
	then
		exitWithError "$NET does not appear to exist" 2
	fi
fi

if [ -z "$DEV" ]
then
	exitWithError "DEV is required (ie. ada0)" 3
fi

if [ -z "$DEV_NAME" ]
then
	exitWithError "DEV_NAME is required (ie. 250.5 - NOTE: device will automatically be prefixed with 'z_')" 4
else
	_INCORRECT_PREFIX=$(echo $DEV_NAME | grep -c ^z_)
	if [ "$_INCORRECT_PREFIX" -gt "0" ]
	then
		DEV_NAME=$(echo $DEV_NAME | sed -e "s/^z_//")
	fi
fi

if [ -z "$HOSTNAME" ]
then
	exitWithError "HOSTNAME is required (ie. acer-router)" 5
fi
