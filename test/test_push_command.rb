#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestPushCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_push_command
		command1 = PushCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(PushCommand, command1)
		assert_instance_of(PushCommand, command1)
		
		command1.shutdown
		
		PushCommand.new(['-h'])
		PushCommand.new(['-d', '2017-01-01'])
		PushCommand.new(['-t', '15:30'])
		PushCommand.new(['-n', 'xyz'])
		PushCommand.new(['--desc', 'xyz'])
		PushCommand.new(['-m', 'xyz'])
		PushCommand.new(['12345', 'abcdef'])
		
		assert_raises(PushCommandError) do
			PushCommand.new(['--xunkn0wn_cmd'])
		end
		assert_raises(PushCommandError) do
			PushCommand.new(['12345', 'abcdef', '1234'])
		end
	end
	
end
