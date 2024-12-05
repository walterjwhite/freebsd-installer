_swap_jail=0

_swap() {
	local swap_device=$(grep swap /etc/fstab 2>/dev/null | awk {'print$1'})
	[ -n "$swap_device" ] && {
		_detail "Activating swap: $swap_device"
		swapon $swap_device
		return 0
	}

	_warn "No swap detected"
}
