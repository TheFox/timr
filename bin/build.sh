#!/usr/bin/env bash

# Run all build scripts.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
pushd "${SCRIPT_BASEDIR}/.."

./bin/build_coverage.sh
./bin/build_api.sh
./bin/build_man.sh
./bin/build_info.sh > build.txt
