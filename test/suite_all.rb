#!/usr/bin/env ruby

# require 'minitest/reporters'
# Minitest::Reporters.use!

require 'simplecov'
SimpleCov.start

require_relative 'test_stack'
require_relative 'test_task'
require_relative 'test_track'



# require_relative 'test_rect'

# require_relative 'test_app_ui'

# require_relative 'test_controller_app'

require_relative 'suite_view'
