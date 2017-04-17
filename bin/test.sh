#!/usr/bin/env bash

# Run all Tests.

SCRIPT_BASEDIR=$(dirname "$0")
RUBYOPT=-w
TZ=Europe/Vienna


set -e
which grep &> /dev/null || { echo 'ERROR: grep not found in PATH'; exit 1; }
which bundler &> /dev/null || { echo 'ERROR: bundler not found in PATH'; exit 1; }

cd "${SCRIPT_BASEDIR}/.."

# What should 'taks' mean? Task?
grep -r -i taks lib man test && { echo 'ERROR: Wrong word found'; exit 1; } || true

bundler exec ./test/suite_all.rb

./bin/test_report.sh
