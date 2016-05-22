#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'


class TestStack < MiniTest::Test
	
	include TheFox::Timr
	
	def test_class_name
		stack1 = Stack.new
		
		assert_equal('TheFox::Timr::Stack', stack1.class.to_s)
	end
	
	def test_has_task
		stack1 = Stack.new
		assert_equal(false, stack1.has_task?)
	end
	
	def test_push_pop
		task1 = Task.new
		task1.name = 'task1'
		task2 = Task.new
		task2.name = 'task2'
		
		stack1 = Stack.new
		assert_equal([], stack1.tasks_texts)
		assert_equal(nil, stack1.task)
		assert_equal(0, stack1.size)
		
		push_res = stack1.push(task1)
		assert_equal(true, push_res)
		assert_equal(task1, stack1.task)
		assert_equal(1, stack1.size)
		assert_equal(true, task1.running?)
		assert_equal(['* task1'], stack1.tasks_texts)
		
		push_res = stack1.push(task2)
		assert_equal(true, push_res)
		assert_equal(task2, stack1.task)
		assert_equal(2, stack1.size)
		assert_equal(true, task2.running?)
		assert_equal(false, task1.running?)
		assert_equal(['| task1', '* task2'], stack1.tasks_texts)
		
		# if !@tasks.include?(task)
		push_res = stack1.push(task2)
		assert_equal(false, push_res)
		assert_equal(2, stack1.size)
		
		pop_res = stack1.pop
		assert_equal(true, pop_res)
		assert_equal(task1, stack1.task)
		assert_equal(1, stack1.size)
		assert_equal(true, task1.running?)
		assert_equal(false, task2.running?)
		assert_equal(['* task1'], stack1.tasks_texts)
		
		pop_res = stack1.pop
		assert_equal(true, pop_res)
		assert_equal([], stack1.tasks_texts)
		assert_equal(nil, stack1.task)
		assert_equal(0, stack1.size)
		
		# if !old.nil?
		pop_res = stack1.pop
		assert_equal(false, pop_res)
	end
	
	def test_pop_all
		task3 = Task.new
		#task3.name = 'task3'
		task4 = Task.new
		#task4.name = 'task4'
		task5 = Task.new
		#task5.name = 'task5'
		
		stack1 = Stack.new
		
		stack1.push(task3)
		assert_equal(true, task3.running?)
		assert_equal(false, task4.running?)
		assert_equal(false, task5.running?)
		
		stack1.push(task4)
		assert_equal(2, stack1.size)
		assert_equal(false, task3.running?)
		assert_equal(true, task4.running?)
		assert_equal(false, task5.running?)
		
		assert_equal(true, stack1.pop_all(task5))
		assert_equal(1, stack1.size)
		
		assert_equal(false, stack1.pop_all(task5))
		assert_equal(1, stack1.size)
		assert_equal(false, task3.running?)
		assert_equal(false, task4.running?)
		assert_equal(true, task5.running?)
		
		task5_track = task5.track
		assert_equal(false, task5_track.nil?)
		
		assert_equal(false, stack1.pop_all(task5))
		assert_equal(false, task3.running?)
		assert_equal(false, task4.running?)
		assert_equal(true, task5.running?)
		
		task5_track = task5.track
		assert_equal(false, task5_track.nil?)
		assert_equal(false, stack1.pop_all(task5, task5_track))
		
		# Pop All with no new Task.
		assert_equal(true, stack1.pop_all)
		assert_equal(0, stack1.size)
		assert_equal(false, task3.running?)
		assert_equal(false, task4.running?)
		assert_equal(false, task5.running?)
	end
end
