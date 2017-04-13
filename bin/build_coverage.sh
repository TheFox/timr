#!/usr/bin/env bash

# Build code coverage for https://timr.fox21.at/coverage/.

SCRIPT_BASEDIR=$(dirname "$0")
RUBYOPT=-w
TZ=Europe/Vienna
export COVERAGE=1


set -e
which bundler &> /dev/null || { echo 'ERROR: bundler not found in PATH'; exit 1; }

cd "${SCRIPT_BASEDIR}/.."

is_local=$1

if [[ "$is_local" = -l ]]; then
	echo 'use local SimpleCov PHPUnit Formatter'
	SIMPLECOV_PHPUNIT_LOAD_PATH=../simplecov-phpunit
fi

bundler exec ./test/suite_all.rb
