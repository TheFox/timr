
GEM_NAME = timr
ALL_TARGETS_EXT = tmp

include Makefile.common

dev:
	TERMKIT_LOAD_PATH=../termkit ruby ./bin/timr -d tmp/timr -c tmp/timr.conf

.PHONY: test
test:
	RUBYOPT=-w TZ=Europe/Vienna TERMKIT_LOAD_PATH=../termkit $(BUNDLER) exec ./test/suite_all.rb -v

.PHONY: cov
cov:
	RUBYOPT=-w TZ=Europe/Vienna TERMKIT_LOAD_PATH=../termkit COVERAGE=1 $(BUNDLER) exec ./test/suite_all.rb -v

doc:
	rdoc README.md lib/timr
