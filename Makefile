
GEM_NAME = timr
ALL_TARGETS_EXT = tmp

include Makefile.common

dev:
	TERMKIT_LOAD_PATH=../termkit $(BUNDLER) exec ./bin/timr -d tmp/timr -c tmp/timr.conf

.PHONY: test
test:
	grep -r -i taks lib; test $$? -gt 0 # What should 'taks' mean? Task?
	RUBYOPT=-w TZ=Europe/Vienna $(BUNDLER) exec ./test/suite_all.rb -v

.PHONY: test_local
test_local:
	RUBYOPT=-w TZ=Europe/Vienna TERMKIT_LOAD_PATH=../termkit $(BUNDLER) exec ./test/suite_all.rb -v
