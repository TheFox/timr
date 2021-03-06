# coding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'timr/version'

Gem::Specification.new do |spec|
	spec.name          = 'timr'
	spec.version       = TheFox::Timr::VERSION
	spec.date          = TheFox::Timr::DATE
	spec.author        = 'Christian Mayer'
	spec.email         = 'christian@fox21.at'
	
	spec.summary       = %q{Timr}
	spec.description   = %q{Time Tracking for Hackers.}
	spec.homepage      = TheFox::Timr::HOMEPAGE
	spec.license       = 'GPL-3.0'
	
	spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }
	spec.bindir        = 'bin'
	spec.executables   = ['timr']
	spec.require_paths = ['lib']
	spec.required_ruby_version = '>=2.1.0'
	
	spec.add_development_dependency 'minitest', '~>5.8'
	spec.add_development_dependency 'simplecov', '~>0.12'
	spec.add_development_dependency 'simplecov-phpunit', '~>1.0'
	spec.add_development_dependency 'pry', '~>0.10'
	
	spec.add_runtime_dependency 'uuid', '~>2.3'
	spec.add_runtime_dependency 'term-ansicolor', '~>1.4'
	#spec.add_runtime_dependency 'terminal-table', '~>1.7'
	# spec.add_runtime_dependency 'activesupport', '~>5.0'
	spec.add_runtime_dependency 'chronic_duration', '~>0.10'
	# spec.add_runtime_dependency 'progress_bar', '~>1.1'
	# spec.add_runtime_dependency 'ruby-progressbar', '~>1.8'
	spec.add_runtime_dependency 'thefox-ext', '~>1.5'
	
	# spec.add_runtime_dependency 'sqlite3', '~>1.3'
	# spec.add_runtime_dependency 'rom-sql', '~>1.2'
	# spec.add_runtime_dependency 'rom-yaml', '~>1.0'
	# spec.add_runtime_dependency 'rom-repository', '~>1.3'
	# spec.add_runtime_dependency 'timecop', '~>0.8'
	
	spec.post_install_message = %q{See 'timr --help' for more details.}
end
