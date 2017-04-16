#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestForeignIdDb < MiniTest::Test
	
	include TheFox::Timr::Model
	include TheFox::Timr::Error
	
	def test_foreign_id_db
		db1 = ForeignIdDb.new
		assert_equal(0, db1.foreign_ids.count)
		
		task_id = db1.get_task_id('abc')
		assert_nil(task_id)
		
		task1 = Task.new
		assert_equal(true, db1.add_task(task1, 'abc'))
		assert_equal('abc', task1.foreign_id)
		assert_equal(false, db1.add_task(task1, 'abc'))
		assert_equal('abc', task1.foreign_id)
		
		task_id = db1.get_task_id('abc')
		assert_equal(task1.id, task_id)
		
		assert_raises(ForeignIdError) do
			task2 = Task.new
			assert_equal(false, db1.add_task(task2, 'abc'))
		end
		
		task3 = Task.new
		assert_equal(true, db1.add_task(task3, 'xyz ')) # strip!
		assert_equal('xyz', task3.foreign_id)
		
		task_id = db1.get_task_id(' xyz ')
		assert_equal(task3.id, task_id)
		
		task_id = db1.get_task_id('xyz')
		assert_equal(task3.id, task_id)
		
		db1.remove_task(task3)
		task_id = db1.get_task_id('xyz')
		assert_nil(task_id)
	end
	
end
