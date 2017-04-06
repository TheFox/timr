#!/usr/bin/env bash

DATE=$(date +"%F")
SCRIPT_BASEDIR=$(dirname "$0")

set -e
which ronn &> /dev/null || { echo 'ronn not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/../man"

while read -r file; do
	echo "file: '$file'"
	tmp_file="${file}.tmp"
	cp "$file" "$tmp_file"
	{
		echo
		cat _footer
	} >> "$tmp_file"
	ronn -w --date=$DATE --manual='Timr Manual' --organization='FOX21.at' "$tmp_file"
done <<< "$(find . -type f -name '*.ronn')"
