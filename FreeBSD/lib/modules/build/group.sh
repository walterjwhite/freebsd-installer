_group() {
	local group_conf
	for group_conf in $@; do
		_group_add $group_conf
	done
}

_group_add() {
	. $1

	_detail " add group: $1 $groupName $gid"
	pw groupadd -n $groupName -g $gid

	unset groupName gid
}
