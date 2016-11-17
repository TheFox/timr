#!/usr/bin/env ruby

if ENV['COVERAGE'] && ENV['COVERAGE'].to_i != 0
	require 'simplecov'
	require 'simplecov-phpunit'
	
	SimpleCov.formatter = SimpleCov::Formatter::PHPUnit
	SimpleCov.start do
		add_filter 'test'
		add_filter 'timr2'
	end
end

require_relative 'test_app_controller'
require_relative 'test_help_view_controller'
require_relative 'test_stack'
require_relative 'test_task'
require_relative 'test_task_manager'
require_relative 'test_track'
require_relative 'test_title_view'
