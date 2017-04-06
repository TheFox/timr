#!/usr/bin/env bash

# DATE=$(date +"%F %T %z")
SCRIPT_BASEDIR=$(dirname "$0")


set -e
which rdoc &> /dev/null || { echo 'ERROR: rdoc not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

rdoc README.md lib/timr
