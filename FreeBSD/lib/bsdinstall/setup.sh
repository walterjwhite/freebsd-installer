_setup() {
	_INSTALLATION_PATH=$(mktemp -d)
	_INSTALLATION_SCRIPT=$_INSTALLATION_PATH/bsdinstall.script

	PARTITIONS=$_CONF_FREEBSD_INSTALLER_DEV
	DISTRIBUTIONS="kernel.txz base.txz"

	ZFSBOOT_PARTITION_SCHEME="GPT"
	ZFSBOOT_BOOT_TYPE="BIOS+UEFI"

	[ -z "$ZFSBOOT_POOL_NAME" ] && ZFSBOOT_POOL_NAME=z_${_CONF_FREEBSD_INSTALLER_DEV_NAME}

	ZFSBOOT_SWAP_ENCRYPTION=yes
	ZFSBOOT_SWAP_SIZE=0

	ZFSBOOT_GELI_ENCRYPTION=yes
	ZFSBOOT_DISKS=${_CONF_FREEBSD_INSTALLER_DEV}

	nonInteractive=YES

	IN_CHROOT=1

	env | _sed_remove_nonprintable_characters | sed -e 's/^/export /' -e 's/=/="/' -e 's/$/"/' >>$_INSTALLATION_SCRIPT
}

_setup_dev_name_using_map() {
	[ -z "$_CONF_FREEBSD_INSTALLER_DEV_NAME_MAP" ] && return 1

	local device_serial_number=$(geom disk list $_CONF_FREEBSD_INSTALLER_DEV | grep ident | awk {'print$2'})

	local device_serial_number_entry
	local device_serial_number_entry_key
	local device_serial_number_entry_value
	for device_serial_number_entry in $(printf '%s\n' $_CONF_FREEBSD_INSTALLER_DEV_NAME_MAP); do
		device_serial_number_entry_key=${device_serial_number_entry%%:*}
		device_serial_number_entry_value=${device_serial_number_entry#*:}

		if [ "$device_serial_number_entry_key" = "$device_serial_number" ]; then
			ZFSBOOT_POOL_NAME=z_${device_serial_number_entry_value}
			_CONF_FREEBSD_INSTALLER_DEV_NAME=$device_serial_number_entry_value

			_info "Using $_CONF_FREEBSD_INSTALLER_DEV [$ZFSBOOT_POOL_NAME|$_CONF_FREEBSD_INSTALLER_DEV_NAME]"
			return
		fi
	done
}
