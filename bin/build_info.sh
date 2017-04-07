#!/usr/bin/env bash

# Build build.txt file for https://timr.fox21.at/build.txt.

DATE=$(date +"%F %T %z")
SCRIPT_BASEDIR=$(dirname "$0")


cd "${SCRIPT_BASEDIR}/.."

RUBY_VERSION=$(ruby -e "print RUBY_VERSION")
TERMKIT_VERSION=$(ruby -rtermkit -e "print %{#{TheFox::TermKit::VERSION} (#{TheFox::TermKit::DATE})}")
TIMR_VERSION=$(ruby -I lib/timr -rversion -e "print %{#{TheFox::Timr::VERSION} (#{TheFox::Timr::DATE})}")

printf "%s

ruby: %s
termkit: %s
timr: %s

--- build ---
id: %s
ref: %s@%s
stage: %s
server: %s %s
" "${DATE}" "${RUBY_VERSION}" "${TERMKIT_VERSION}" "${TIMR_VERSION}" "${CI_BUILD_ID}" "${CI_BUILD_REF}" "${CI_BUILD_REF_NAME}" "${CI_BUILD_STAGE}" "${CI_SERVER_NAME}" "${CI_SERVER_VERSION}"
