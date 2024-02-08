_enable_sshd() {
	if [ ! -e $_ROOT/etc/ssh/ssh_host_ecdsa_key ]; then
		_warn "Generating SSH Host Key + enabling SSHd"
		chroot $_ROOT service sshd onestart && sysrc sshd_enable=YES && sysrc hostname=freebsd-installer && service sshd onestop

		mkdir -p $HOME/.ssh
		cat $_ROOT/etc/ssh/ssh_host_*_key.pub | sed -e 's/^/freebsd-installer /' >>$HOME/.ssh/known_hosts

		cp /etc/ssh/sshd_config $_ROOT/etc/ssh/
	else
		_warn "SSH Host Key already exists, skipping"
	fi
}
