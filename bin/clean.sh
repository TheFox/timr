#!/usr/bin/env bash

# Clean up development files.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
which rm &> /dev/null || { echo 'ERROR: rm not found in PATH'; exit 1; }

cd "${SCRIPT_BASEDIR}/.."

rm -frd .bundle
rm -f .setup Gemfile.lock
