#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestContinueCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_continue_command
		command1 = ContinueCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(ContinueCommand, command1)
		assert_instance_of(ContinueCommand, command1)
		
		command1.shutdown
		
		ContinueCommand.new(['-h'])
		ContinueCommand.new(['-d', '2017-01-01'])
		ContinueCommand.new(['-t', '15:30'])
		
		assert_raises(ContinueCommandError) do
			ContinueCommand.new(['unkn0wn_cmd'])
		end
	end
	
end
