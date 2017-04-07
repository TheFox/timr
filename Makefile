
GEM_NAME = timr
ALL_TARGETS_EXT = tmp

include Makefile.common

dev:
	TERMKIT_LOAD_PATH=../termkit $(BUNDLER) exec ./bin/timr -d tmp/timr -c tmp/timr.conf
