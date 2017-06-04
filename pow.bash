#!/bin/bash
set -euo pipefail

# work generator function
# counts rapidly
generator(){
	x=0
	while true; do
		echo $x
		x=$((x+1))
	done
}

# worker function
# takes in the message and a nonce
worker(){
	text="$1"
	nonce="$2"
	length="ffffff"
	msg="$text <$(( ${#length} * 4 )):$nonce>"
	hash="$(echo "$msg" | sha256sum)"
	#echo "$workerid $msg $hash"
	if [ "${hash:0:${#length}}" = "$length" ]; then
		echo "Found it: $msg $hash"
		exit 255
	fi
}

# if worker
if [ -n "${workerid:-}" ]; then
	# pass all cmdline args to this function instead
	worker "$@"
	exit
fi

# if primary
generator | xargs -P $(( "$(grep -c proc /proc/cpuinfo)" + 1)) -n 1 --process-slot-var=workerid "$0" "${1:-This is a message}"
echo "Finished, no results"
