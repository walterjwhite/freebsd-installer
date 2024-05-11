_fstab() {
	local fstab
	local patch_name

	for fstab in $@; do
		patch_name=$(_module_get_patch_name $fstab)

		printf '# %s\n' "$patch_name" >>/etc/fstab
		cat $fstab >>/etc/fstab
		printf '\n' >>/etc/fstab
	done
}
