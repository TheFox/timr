#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'

class TestTaskManager < MiniTest::Test
	
	include TheFox::Timr
	
	def test_task_manager
		FileUtils.mkdir_p('tasks_test')
		
		task1 = Task.new
		task1.start
		task1.stop
		task1.save_to_file('tasks_test/task_1.yml')
		
		taskmanager1 = TaskManager.new('tasks_test')
		assert_instance_of(TaskManager, taskmanager1)
		
		taskmanager1.load
		taskmanager1.save
		taskmanager1.close
	end
	
	def teardown
		FileUtils.rm_r('tasks_test', {:force => true})
	end
	
end
