#!/usr/bin/env ruby

require 'minitest/autorun'
require 'fileutils'
require 'timr'

class TestTaskCommand < MiniTest::Test
	
	include TheFox::Timr::Command
	include TheFox::Timr::Error
	
	def setup
		@tmpdir = Dir.mktmpdir
	end
	
	def teardown
		FileUtils.remove_entry_secure(@tmpdir)
	end
	
	def test_task_command
		command1 = TaskCommand.new
		
		assert_kind_of(BasicCommand, command1)
		assert_kind_of(TaskCommand, command1)
		assert_instance_of(TaskCommand, command1)
		
		command1.shutdown
		
		TaskCommand.new(['-h'])
		TaskCommand.new(['-t'])
		TaskCommand.new(['-n', 'xyz'])
		TaskCommand.new(['--desc', 'xyz'])
		TaskCommand.new(['-e', '1h'])
		TaskCommand.new(['show'])
		TaskCommand.new(['add'])
		TaskCommand.new(['remove'])
		TaskCommand.new(['set'])
		TaskCommand.new(['1234'])
		TaskCommand.new(['xyz']) # OK as --id
		
		assert_raises(TaskCommandError) do
			TaskCommand.new(['--id', 'xyz', '--no-id'])
		end
		assert_raises(TaskCommandError) do
			TaskCommand.new(['--billed', '--unbilled'])
		end
		assert_raises(TaskCommandError) do
			TaskCommand.new(['--billed', '--unbilled'])
		end
		assert_raises(TaskCommandError) do
			TaskCommand.new(['--hourly-rate', 10, '--no-hourly-rate'])
		end
		assert_raises(TaskCommandError) do
			TaskCommand.new(['--flat-rate', '--no-flat-rate'])
		end
	end
	
	# Incomplete tests.
	def test_run_set
		command1 = TaskCommand.new(['set'])
		command1.cwd = @tmpdir
		assert_raises(TaskCommandError) do
			command1.run
		end
		
		command1 = TaskCommand.new(['set', 'task1'])
		command1.cwd = @tmpdir
		assert_raises(TaskCommandError) do
			command1.run
		end
	end
	
end
