#!/bin/sh

# setup temporary ssh key
if [ "$NET" ]
then
	ifconfig $NET up

	dhclient $NET

    # force information to be updated
    resolvconf -u

    if [ -z "$_SKIP_SSH_SETUP" ]
    then
        _SSH_KEY=/tmp/id_$_SSH_KEYTYPE
        export _SSH_KEY

        ssh-keygen -t $_SSH_KEYTYPE -N "" -f $_SSH_KEY

        # start ssh agent
        eval "$(ssh-agent -s)"
        ssh-add $_SSH_KEY

        ssh-copy-id $GIT_HOST
    fi
fi