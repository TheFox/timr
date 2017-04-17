#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestResetCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_reset_command
		command1 = ResetCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(ResetCommand, command1)
		assert_instance_of(ResetCommand, command1)
		
		command1.shutdown
		
		ResetCommand.new(['-h'])
		ResetCommand.new(['--stack'])
		
		assert_raises(ResetCommandError) do
			ResetCommand.new(['xunkn0wn_cmd'])
		end
	end
	
end
