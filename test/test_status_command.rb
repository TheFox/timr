#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestStatusCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_status_command
		command1 = StatusCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(StatusCommand, command1)
		assert_instance_of(StatusCommand, command1)
		
		command1.shutdown
		
		StatusCommand.new(['-h'])
		StatusCommand.new(['-f'])
		StatusCommand.new(['-r'])
		
		assert_raises(StatusCommandError) do
			StatusCommand.new(['xunkn0wn_cmd'])
		end
	end
	
end
