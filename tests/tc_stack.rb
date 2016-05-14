#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'


class TestStack < MiniTest::Test
	def test_class_name
		stack = TheFox::Timr::Stack.new
		
		assert_equal('TheFox::Timr::Stack', stack.class.to_s)
	end
	
	def test_has_task
		stack = TheFox::Timr::Stack.new
		assert_equal(false, stack.has_task?)
	end
	
	def test_push_pop
		task1 = TheFox::Timr::Task.new
		task1.name = 'task1'
		task2 = TheFox::Timr::Task.new
		task2.name = 'task2'
		
		stack = TheFox::Timr::Stack.new
		assert_equal([], stack.tasks_texts)
		assert_equal(nil, stack.task)
		assert_equal(0, stack.length)
		
		push_res = stack.push(task1)
		assert_equal(true, push_res)
		assert_equal(task1, stack.task)
		assert_equal(1, stack.length)
		assert_equal(true, task1.running?)
		assert_equal(['* task1'], stack.tasks_texts)
		
		push_res = stack.push(task2)
		assert_equal(true, push_res)
		assert_equal(task2, stack.task)
		assert_equal(2, stack.length)
		assert_equal(true, task2.running?)
		assert_equal(false, task1.running?)
		assert_equal(['| task1', '* task2'], stack.tasks_texts)
		
		# if !@tasks.include?(task)
		push_res = stack.push(task2)
		assert_equal(false, push_res)
		assert_equal(2, stack.length)
		
		pop_res = stack.pop
		assert_equal(true, pop_res)
		assert_equal(task1, stack.task)
		assert_equal(1, stack.length)
		assert_equal(true, task1.running?)
		assert_equal(false, task2.running?)
		assert_equal(['* task1'], stack.tasks_texts)
		
		pop_res = stack.pop
		assert_equal(true, pop_res)
		assert_equal([], stack.tasks_texts)
		assert_equal(nil, stack.task)
		assert_equal(0, stack.length)
		
		# if !old.nil?
		pop_res = stack.pop
		assert_equal(false, pop_res)
		
		
		# Pop All
		task3 = TheFox::Timr::Task.new
		task3.name = 'task3'
		task4 = TheFox::Timr::Task.new
		task4.name = 'task4'
		task5 = TheFox::Timr::Task.new
		task5.name = 'task5'
		
		stack.push(task3)
		stack.push(task4)
		assert_equal(2, stack.length)
		pop_all_res = stack.pop_all(task5)
		assert_equal(true, pop_all_res)
		assert_equal(1, stack.length)
		
		pop_all_res = stack.pop_all(task5)
		assert_equal(false, pop_all_res)
		assert_equal(1, stack.length)
		
		assert_equal(false, task3.running?)
		assert_equal(false, task4.running?)
		assert_equal(true, task5.running?)
		
		pop_all_res = stack.pop_all
		assert_equal(true, pop_all_res)
		assert_equal(0, stack.length)
	end
end
