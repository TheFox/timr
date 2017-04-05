#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestReportCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def test_report_command
		command1 = ReportCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(ReportCommand, command1)
		assert_instance_of(ReportCommand, command1)
		
		command1.shutdown
		
		ReportCommand.new(['-h'])
		ReportCommand.new(['-a'])
		ReportCommand.new(['--tasks'])
		ReportCommand.new(['-t'])
		ReportCommand.new(['--tracks'])
		ReportCommand.new(['-f'])
		
		assert_raises(ReportCommandError) do
			ReportCommand.new(['xunkn0wn_cmd'])
		end
		
		assert_raises(ReportCommandError) do
			ReportCommand.new(['--csv'])
		end
	end
	
end
