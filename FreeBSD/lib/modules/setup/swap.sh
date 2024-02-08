_swap() {
	local swap_device=$(grep swap /etc/fstab 2>/dev/null | awk {'print$1'})
	[ -n "$swap_device" ] && swapon $swap_device
}
