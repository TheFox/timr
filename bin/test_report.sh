#!/usr/bin/env bash

# Test Report Command.

DATE=$(date +"%F_%H%M%S")
SCRIPT_BASEDIR=$(dirname "$0")


set -e
cd "${SCRIPT_BASEDIR}/.."
option=$1

mkdir -p tmp
tmpdir=$(mktemp -d tmp/test_report_XXXXX)
cwd="${tmpdir}/defaultc"
tasks_csv_file="${tmpdir}/tasks.csv"
tracks_csv_file="${tmpdir}/tracks.csv"

bundler exec ./bin/timr -C "$cwd" task add --id t1 -n t1 # full
bundler exec ./bin/timr -C "$cwd" task add --id t2 -n t2 # empty
bundler exec ./bin/timr -C "$cwd" task add --id t3 -n t3 # includes a normal track and empty track
bundler exec ./bin/timr -C "$cwd" task add --id t4 -n t4 # includes only an empty track

# Show Tasks
bundler exec ./bin/timr -C "$cwd" task show t1
bundler exec ./bin/timr -C "$cwd" task show t2
bundler exec ./bin/timr -C "$cwd" task show t3
bundler exec ./bin/timr -C "$cwd" task show t4

# Task 1
bundler exec ./bin/timr -C "$cwd" track add \
	--start-date 2017-01-01 --start-time 01:00 \
	--end-date 2017-01-01 --end-time 02:00 \
	--billed \
	-m 'task1_track1' t1

bundler exec ./bin/timr -C "$cwd" track add \
	--start-date 2017-01-02 --start-time 01:00 \
	--end-date 2017-01-02 --end-time 03:00 \
	-m 'task1_track2' t1

# Task 2 empty

# Task 3
bundler exec ./bin/timr -C "$cwd" track add \
	--start-date 2017-01-03 --start-time 01:00 \
	--end-date 2017-01-03 --end-time 03:00 \
	-m 'task3_track1' t3

bundler exec ./bin/timr -C "$cwd" track add t3

# Task 4
bundler exec ./bin/timr -C "$cwd" track add \
	--start-date 2017-01-04 --start-time 01:00 \
	--end-date 2017-01-04 --end-time 04:00 \
	-m 'task4_track1' t4

bundler exec ./bin/timr -C "$cwd" track add t4

# Show Tasks
bundler exec ./bin/timr -C "$cwd" task show t1
bundler exec ./bin/timr -C "$cwd" task show t2
bundler exec ./bin/timr -C "$cwd" task show t3
bundler exec ./bin/timr -C "$cwd" task show t4

# Report to STDOUT.
bundler exec ./bin/timr -C "$cwd" report --tasks --all
bundler exec ./bin/timr -C "$cwd" report --tasks --all --billed
bundler exec ./bin/timr -C "$cwd" report --tasks --all --unbilled
bundler exec ./bin/timr -C "$cwd" report --tracks --all
bundler exec ./bin/timr -C "$cwd" report --tracks --all --billed
bundler exec ./bin/timr -C "$cwd" report --tracks --all --unbilled

# Report to files.
bundler exec ./bin/timr -C "$cwd" report --tasks --all --csv "${tasks_csv_file}"
bundler exec ./bin/timr -C "$cwd" report --tracks --all --csv "${tracks_csv_file}"

# Open under macOS.
if [[ "$option" = "-o" ]]; then
	open "${tasks_csv_file}"
	open "${tracks_csv_file}"
fi
