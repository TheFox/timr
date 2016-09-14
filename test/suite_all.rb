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
		add_filter 'lib/timr'
	end
end

require_relative 'termkit/test_app'
# require_relative 'termkit/test_app_curses'
require_relative 'termkit/test_app_ui'
require_relative 'termkit/test_content_view'
require_relative 'termkit/test_controller'
require_relative 'termkit/test_controller_app'
require_relative 'termkit/test_controller_view'
require_relative 'termkit/test_event_key'
require_relative 'termkit/test_exception_event_unhandled'
require_relative 'termkit/test_exception_initialized_not_class_parent'
require_relative 'termkit/test_point'
require_relative 'termkit/test_rect'
require_relative 'termkit/test_size'
require_relative 'termkit/test_view'
require_relative 'termkit/test_view_table'
require_relative 'termkit/test_view_table_cell'
require_relative 'termkit/test_view_text'

require_relative 'timr/test_stack'
require_relative 'timr/test_task'
require_relative 'timr/test_track'
require_relative 'timr/test_view_title'
