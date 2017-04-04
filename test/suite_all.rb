#!/usr/bin/env ruby

if ENV['COVERAGE'] && ENV['COVERAGE'].to_i != 0
	require 'simplecov'
	require 'simplecov-phpunit'
	
	SimpleCov.formatter = SimpleCov::Formatter::PHPUnit
	SimpleCov.start do
		add_filter 'test'
	end
end

# require_relative 'test_simple_opt_parser'

require_relative 'test_track'
require_relative 'test_task'
require_relative 'test_duration'
require_relative 'test_progressbar'
require_relative 'test_status'
require_relative 'test_translation_helper'
