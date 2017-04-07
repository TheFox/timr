#!/usr/bin/env bash

# Release gem to https://rubygems.org.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
which gem &> /dev/null || { echo 'ERROR: gem not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

# Load Environment Variables
[[ -f .env ]] && source .env

if [[ -z "${GEMSPEC_FILE}" ]] ; then
	echo 'ERROR: one of the environment variables is missing'
	echo "GEMSPEC_FILE: '${GEMSPEC_FILE}'"
	exit 1
fi

gem_file=$(gem build "${GEMSPEC_FILE}" 2> /dev/null | grep 'File:' | tail -1 | awk '{ print $2 }')

echo "push gem file '$gem_file'"
gem push "$gem_file"

# Create tmp directory.
if [[ ! -d tmp ]]; then
	mkdir -p tmp
	chmod u=rwx,go-rwx tmp
fi
mv -v -i "$gem_file" tmp
