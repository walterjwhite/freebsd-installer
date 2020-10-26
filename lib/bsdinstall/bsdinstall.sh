#!/bin/sh

_INSTALLATION_SCRIPT=$_INSTALLATION_PATH/bsdinstall.script

# setup defaults
cp _LIBRARY_PATH_/_APPLICATION_NAME_/bsdinstall/defaults   $_INSTALLATION_SCRIPT

# add any env variables
env | sed -e "s/^/export /"                             >> $_INSTALLATION_SCRIPT

# setup default script
cat _LIBRARY_PATH_/_APPLICATION_NAME_/bsdinstall/script >> $_INSTALLATION_SCRIPT