_fstab() {
	local fstab
	for fstab in $@; do
		_PATCH_NAME=$(printf '%s' "$fstab" | $_CONF_INSTALL_GNU_GREP -Po '^.*.\.patch' |
			sed -e "s/^\.\///" -e "s/\.patch$//" -e "s/^patches\///")

		printf '# %s\n' "$_PATCH_NAME" >>/etc/fstab
		cat $fstab >>/etc/fstab
		printf '\n' >>/etc/fstab
	done
}
