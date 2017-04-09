#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestStopCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_stop_command
		command1 = StopCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(StopCommand, command1)
		assert_instance_of(StopCommand, command1)
		
		command1.shutdown
		
		StopCommand.new(['-h'])
		StopCommand.new(['-d', '2017-01-01'])
		StopCommand.new(['-t', '15:30'])
		StopCommand.new(['--sd', '2017-01-01'])
		StopCommand.new(['--st', '15:30'])
		StopCommand.new(['-m', 'xyz'])
		
		assert_raises(StopCommandError) do
			StopCommand.new(['xunkn0wn_cmd'])
		end
	end
	
end
