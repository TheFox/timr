#!/usr/bin/env bash

# Generate dev data.

SCRIPT_BASEDIR=$(dirname "$0")


set -e
cd "${SCRIPT_BASEDIR}/.."

cwd="tmp/dev"
mkdir -p "$cwd"

bundler exec ./bin/timr -C "$cwd" task add --id t1 -n t1
bundler exec ./bin/timr -C "$cwd" task add --id t2 -n t2
bundler exec ./bin/timr -C "$cwd" task add --id t3 -n t3
bundler exec ./bin/timr -C "$cwd" task add --id t4 -n t4

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

bundler exec ./bin/timr -C "$cwd" start t4 -t 01:00
bundler exec ./bin/timr -C "$cwd" stop -t 02:00

bundler exec ./bin/timr -C "$cwd" start t1 -t 03:00
bundler exec ./bin/timr -C "$cwd" push t2
