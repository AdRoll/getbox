#!/bin/bash
set -e -o pipefail

GETBOX=./getbox
TYPE=${1:-r4.2xlarge}

#BOX=$(${GETBOX} get ${TYPE} --name unittest)
BOX=$(${GETBOX} ssh unittest)
cleanup() {
    while echo "y" | ${GETBOX} kill unittest ; do
        sleep 0.1
    done
}

print_() {
	echo $1 >&2
}

wait_path() {
	local path="$1";
	local timeout_=${2:-30}
	local t1=$(date +%s)
	local deadline=$(expr ${t1} + ${timeout_})

	while true ; do
		if ssh ${BOX} "test -e ${path}" ; then
			return
		fi

		if [ "$(date +%s)" -gt "${deadline}" ]; then
			print_ "Failed: $path doesnt exist, check ${BOX}"
			#cleanup
			exit 1
		fi
	done
}

wait_path /mnt

ssh ${BOX} "sudo cp -r /etc/ /mnt/"

print_ "SUCCEEDED cleaning up"
#cleanup
