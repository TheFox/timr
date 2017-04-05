#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestStartCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_start_command
		command1 = StartCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(StartCommand, command1)
		assert_instance_of(StartCommand, command1)
		
		command1.shutdown
		
		StartCommand.new(['-h'])
		StartCommand.new(['-d', '2017-01-01'])
		StartCommand.new(['-t', '15:30'])
		StartCommand.new(['-m', 'xyz'])
		StartCommand.new(['-n', 'xyz'])
		StartCommand.new(['--desc', 'xyz'])
		StartCommand.new(['12345', 'abcdef'])
		
		assert_raises(StartCommandError) do
			StartCommand.new(['--xunkn0wn_cmd'])
		end
		assert_raises(StartCommandError) do
			StartCommand.new(['12345', 'abcdef', '1234'])
		end
	end
	
end
