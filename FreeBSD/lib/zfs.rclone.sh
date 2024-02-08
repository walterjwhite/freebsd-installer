_ZFS_RCLONE_PACKAGE=rclone

_zfs_rclone() {
	local rclone_patch_path=patches/zfs-rclone.patch/rclone.post-run
	mkdir -p $(dirname $rclone_patch_path)

	if [ -n "$_ZFS_RCLONE_TARGET" ]; then
		[ ! -e $rclone_patch_path ] && printf 'pkg install -yq %s\n' $_ZFS_RCLONE_PACKAGE >>$rclone_patch_path

		zfs set rclone:target=$_ZFS_RCLONE_TARGET $_ZFS_VOLUME
	fi

	[ -n "$_ZFS_RCLONE_PATH" ] && zfs set rclone:path=$_ZFS_RCLONE_PATH $_ZFS_VOLUME
}
