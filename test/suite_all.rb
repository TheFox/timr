#!/usr/bin/env ruby

# require 'minitest/reporters'
# Minitest::Reporters.use!

if ENV['COVERAGE'] && ENV['COVERAGE'].to_i != 0
	require 'simplecov'
	require 'simplecov-phpunit'
	
	SimpleCov.formatter = SimpleCov::Formatter::PHPUnit
	SimpleCov.start do
		add_filter 'test'
		add_filter 'timr2'
	end
end

require_relative 'timr/test_stack'
require_relative 'timr/test_task'
require_relative 'timr/test_track'
require_relative 'timr/test_view_title'
