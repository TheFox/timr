#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestPopCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_pop_command
		command1 = PopCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(PopCommand, command1)
		assert_instance_of(PopCommand, command1)
		
		command1.shutdown
		
		PopCommand.new(['-h'])
		PopCommand.new(['-d', '2017-01-01'])
		PopCommand.new(['-t', '15:30'])
		
		assert_raises(PopCommandError) do
			PopCommand.new(['unkn0wn_cmd'])
		end
	end
	
end
