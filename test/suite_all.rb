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

require_relative 'test_basic_model'
require_relative 'test_track'
require_relative 'test_task'
require_relative 'test_stack'
require_relative 'test_config'
require_relative 'test_duration'
require_relative 'test_progressbar'
require_relative 'test_status'
require_relative 'test_translation_helper'

require_relative 'test_continue_command'
require_relative 'test_help_command'
require_relative 'test_log_command'
require_relative 'test_pause_command'
require_relative 'test_pop_command'
require_relative 'test_push_command'
require_relative 'test_report_command'
require_relative 'test_start_command'
require_relative 'test_status_command'
require_relative 'test_stop_command'
require_relative 'test_task_command'
require_relative 'test_track_command'
require_relative 'test_version_command'
