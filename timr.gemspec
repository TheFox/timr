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
	
	spec.summary       = %q{Timr - Time Tracking for Hackers.}
	spec.description   = %q{Timr is a time tracking tool for the Command-line, written in Ruby. You can track your time spent for a specific project. The main focus of this tool is to use it on the Command-line and make automatic reports. All data are stored in YAML files. So editing can also be done by using your favorite editor.}
	spec.homepage      = TheFox::Timr::HOMEPAGE
	spec.license       = 'MIT'
	
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
	spec.add_runtime_dependency 'chronic_duration', '~>0.10'
	spec.add_runtime_dependency 'thefox-ext', '~>1.5'
	
	# spec.post_install_message = %q{See 'timr --help' for more details.}
end
