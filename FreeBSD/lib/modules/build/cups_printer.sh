_cups_printer() {
	local cups_printer_conf
	for cups_printer_conf in $@; do
		_cups_printer_add $cups_printer_conf
	done
}

_cups_printer_add() {
	_cups_printer_exists $1 || {
		_info "Adding $1"
		cat $1 >>/usr/local/etc/cups/printers.conf
	}
}

_cups_printer_exists() {
	[ ! -e /usr/local/etc/cups/printers.conf ] && return 1

	local printer_uuid=$(grep ^UUID $1 | sed -e 's/UUID urn:uuid://')
	if [ $(grep -c $printer_uuid /usr/local/etc/cups/printers.conf) -eq 0 ]; then
		return 1
	fi

	_warn "Printer ($printer_uuid) already exists"
	return 0
}
