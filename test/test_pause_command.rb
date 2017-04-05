#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestPauseCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_pause_command
		command1 = PauseCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(PauseCommand, command1)
		assert_instance_of(PauseCommand, command1)
		
		command1.shutdown
		
		PauseCommand.new(['-h'])
		PauseCommand.new(['-d', '2017-01-01'])
		PauseCommand.new(['-t', '15:30'])
		
		assert_raises(PauseCommandError) do
			PauseCommand.new(['unkn0wn_cmd'])
		end
	end
	
end
