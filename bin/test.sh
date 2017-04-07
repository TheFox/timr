#!/usr/bin/env bash

# Run Unit Tests.

SCRIPT_BASEDIR=$(dirname "$0")
RUBYOPT=-w
TZ=Europe/Vienna


set -e
which bundler &> /dev/null || { echo 'bundler not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

# What should 'taks' mean? Task?
grep -r -i taks lib test && { echo 'ERROR: Wrong word found'; exit 1; } || true

bundler exec ./test/suite_all.rb
