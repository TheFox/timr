#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestVersionCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	
	def test_version_command
		command1 = VersionCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(VersionCommand, command1)
		assert_instance_of(VersionCommand, command1)
		
		command1.shutdown
	end
	
end
