#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestLogCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_log_command
		command1 = LogCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(LogCommand, command1)
		assert_instance_of(LogCommand, command1)
		
		command1.shutdown
		
		LogCommand.new(['-h'])
		LogCommand.new(['-a'])
		LogCommand.new(['-s', '2017-01-01 15:30'])
		LogCommand.new(['-e', '2017-01-01 15:31'])
		LogCommand.new(['--sd', '2017-01-01'])
		LogCommand.new(['--st', '15:31'])
		LogCommand.new(['--ed', '2017-01-01'])
		LogCommand.new(['--et', '15:31'])
		
		assert_raises(LogCommandError) do
			LogCommand.new(['unkn0wn_cmd'])
		end
	end
	
end
