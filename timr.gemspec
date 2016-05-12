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
	
	spec.add_dependency 'curses', '~>1.0'
	spec.add_dependency 'uuid', '~>2.3'
	
	spec.add_dependency 'thefox-ext', '~>1.4'
end
