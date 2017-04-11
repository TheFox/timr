#!/usr/bin/env bash

# Build manual pages.

DATE=$(date +"%F")
SCRIPT_BASEDIR=$(dirname "$0")


set -e
which ronn &> /dev/null || { echo 'ERROR: ronn not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/../man"

for file in \
	timr-continue.1.ronn \
	timr-log.1.ronn \
	timr-pause.1.ronn \
	timr-pop.1.ronn \
	timr-push.1.ronn \
	timr-report.1.ronn \
	timr-start.1.ronn \
	timr-status.1.ronn \
	timr-stop.1.ronn \
	timr-task.1.ronn \
	timr-track.1.ronn \
	timr-ftime.7.ronn ; do
	
	echo "file: '$file'"
	tmp_file="${file}.tmp"
	cp "$file" "$tmp_file"
	{
		echo
		cat _footer
	} >> "$tmp_file"
done

ronn -w --date="$DATE" --manual='Timr Manual' --organization='FOX21.at' timr.1.ronn timr-*.ronn.tmp

echo 'done'
