#!/usr/bin/env bash

DATE=$(date +"%F")
SCRIPT_BASEDIR=$(dirname "$0")

set -e
which ronn &> /dev/null || { echo 'ronn not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/../man"

while read -r dir; do
	echo "dir: '$dir'"
	pushd "$dir"
	
	find . -type f -name '*.ronn' -exec ronn -w --date=$DATE --manual='Timr Manual' --organization='FOX21.at' {} \;
	
	popd
done <<< "$(find . -type d)"
