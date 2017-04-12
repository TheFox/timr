#!/usr/bin/env bash

# Install Gem local.

SCRIPT_BASEDIR=$(dirname "$0")


option=$1
set -e
which gem &> /dev/null || { echo 'ERROR: gem not found in PATH'; exit 1; }
which bundler &> /dev/null || { echo 'ERROR: bundler not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

# Load Environment Variables
[[ -f .env ]] && source .env

if [[ -z "${GEMSPEC_FILE}" ]] ; then
	echo 'ERROR: one of the environment variables is missing'
	echo "GEMSPEC_FILE: '${GEMSPEC_FILE}'"
	exit 1
fi

gem_file=$(gem build "${GEMSPEC_FILE}" 2> /dev/null | grep 'File:' | tail -1 | awk '{ print $2 }')

if [[ -z "$gem_file" ]] ; then
	echo 'ERROR: gem_file variable not set'
	exit 1
fi

echo "install gem file '$gem_file'"
gem install "$gem_file"

# Create tmp directory.
if [[ ! -d tmp ]]; then
	mkdir -p tmp
	chmod u=rwx,go-rwx tmp
fi

if [[ "$option" = "-f" ]]; then
	mv -v "$gem_file" tmp
else
	mv -v -i "$gem_file" tmp
fi
