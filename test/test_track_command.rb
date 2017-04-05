#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestTrackCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_track_command
		command1 = TrackCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(TrackCommand, command1)
		assert_instance_of(TrackCommand, command1)
		
		command1.shutdown
		
		TrackCommand.new(['-h'])
		TrackCommand.new(['-m', 'xyz'])
		TrackCommand.new(['set', '-t', 'xyz'])
		TrackCommand.new(['show', '-t'])
		TrackCommand.new(['add'])
		TrackCommand.new(['remove'])
		TrackCommand.new(['1234'])
		
		assert_raises(TrackCommandError) do
			TrackCommand.new(['xunkn0wn_cmd'])
		end
		assert_raises(TrackCommandError) do
			TrackCommand.new(['--billed', '--unbilled'])
		end
	end
	
end
