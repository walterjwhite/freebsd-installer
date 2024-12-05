_ZFS_ZAP_PACKAGE=zap

_zfs_zap() {
	local zap_patch_path=patches/zfs-zap.patch/zap.post-run
	mkdir -p $(dirname $zap_patch_path)

	if [ -n "$_ZFS_ZAP_SNAP" ]; then
		_warn "Detected ZFS ZAP, setting up zap"

		[ ! -e $zap_patch_path ] && printf 'pkg install -yq %s\n' $_ZFS_ZAP_PACKAGE >>$zap_patch_path
		printf 'zfs allow -u zap bookmark,diff,hold,send,snapshot %s\n' $_ZFS_VOLUME >>$zap_patch_path

		zfs set zap:snap=on $_ZFS_VOLUME
	fi

	[ -n "$_ZFS_ZAP_TTL" ] && zfs set zap:ttl=$_ZFS_ZAP_TTL $_ZFS_VOLUME
	[ -n "$_ZFS_ZAP_BACKUP" ] && zfs set zap:backup=$_ZFS_ZAP_BACKUP $_ZFS_VOLUME

	unset _ZFS_ZAP_TTL _ZFS_ZAP_BACKUP _ZFS_ZAP_SNAP
}
