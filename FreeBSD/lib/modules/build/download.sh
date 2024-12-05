import git:install/download.sh
import git:install/extract.sh

_download() {
	local download_conf
	for download_conf in $@; do
		_do_download $download_conf
	done
}

_do_download() {
	mkdir -p /tmp/downloads

	. $1

	_download $uri
	_OUTPUT=/tmp/downloads/$(basename $_DOWNLOADED_FILE)

	cp $_DOWNLOADED_FILE $_OUTPUT
	if [ -n "$signature" ]; then
		sha256 -c $signature $_OUTPUT 2>/dev/null
		if [ $? -eq 0 ]; then
			printf '\tOK\n'
		else
			printf '\tFAIL\n'
		fi
	fi

	_extract $_OUTPUT
}
