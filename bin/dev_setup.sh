#!/usr/bin/env bash

# Development setup.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
which ruby &> /dev/null || { echo 'ERROR: ruby not found in PATH'; exit 1; }
which bundler &> /dev/null || { echo 'ERROR: bundler not found in PATH'; exit 1; }

pushd "${SCRIPT_BASEDIR}/.."

# Create .env file.
if [[ ! -f .env ]]; then
	cp .env.example .env
fi

bundler install
