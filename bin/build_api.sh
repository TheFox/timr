#!/usr/bin/env bash

# Build API documentation pages for https://timr.fox21.at/api/.
# Former https://timr.fox21.at/doc/.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
which rdoc &> /dev/null || { echo 'ERROR: rdoc not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

# rdoc -C lib/timr
rdoc --op api README.md lib/timr
