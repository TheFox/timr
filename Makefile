
GEM_NAME = timr
ALL_TARGETS_EXT = tmp

include Makefile.common

dev:
	RUBYOPT=-rbundler/setup ruby --debug ./bin/timr -d tmp/timr -c tmp/timr.conf

.PHONY: test
test:
	RUBYOPT=-w TZ=Europe/Vienna $(BUNDLER) exec ./tests/ts_all.rb -v
