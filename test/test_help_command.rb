#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestHelpCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_help_command
		command1 = HelpCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(HelpCommand, command1)
		assert_instance_of(HelpCommand, command1)
		
		command1.shutdown
	end
	
end
