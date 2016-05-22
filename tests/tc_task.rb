#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'


class TestTask < MiniTest::Test
	
	include TheFox::Timr
	
	def test_class_name
		task1 = Task.new
		
		assert_equal('TheFox::Timr::Task', task1.class.to_s)
	end
	
	def test_save_load
		task1 = Task.new
		
		file_path = task1.save_to_file('tmp')
		assert_equal(false, File.exist?(file_path))
		
		task1.name = 'task1'
		task1.description = 'hello world1'
		file_path = task1.save_to_file('tmp')
		assert_equal(true, File.exist?(file_path))
		
		task2 = Task.new
		task2.load_from_file(file_path)
		
		assert_equal(task1.id, task2.id)
		assert_equal('task1', task2.name)
		assert_equal('hello world1', task2.description)
		
		FileUtils.rm_r(file_path)
	end
	
	def test_status
		task1 = Task.new
		assert_equal(false, task1.running?)
		assert_equal(?., task1.status)
		
		task1.start
		assert_equal(true, task1.running?)
		assert_equal(?>, task1.status)
		
		task1.stop
		assert_equal(false, task1.running?)
		assert_equal(?., task1.status)
		
		task1.start
		assert_equal(true, task1.running?)
		assert_equal(?>, task1.status)
		
		task1.pause
		assert_equal(false, task1.running?)
		assert_equal(true, task1.paused?)
		assert_equal(?|, task1.status)
		
		task1.stop
		assert_equal(false, task1.running?)
		assert_equal(?., task1.status)
	end
	
	def test_start_stop
		task1 = Task.new
		assert_equal(false, task1.running?)
		assert_equal(false, task1.has_track?)
		assert_equal(0, task1.timeline.length)
		
		assert_equal(true, task1.start)
		assert_equal(true, task1.running?)
		assert_equal(true, task1.has_track?)
		assert_equal(1, task1.timeline.length)
		
		task1.stop
		assert_equal(false, task1.running?)
		assert_equal(false, task1.has_track?)
		assert_equal(1, task1.timeline.length)
		
		assert_equal(true, task1.start)
		assert_equal(true, task1.running?)
		assert_equal(true, task1.has_track?)
		assert_equal(2, task1.timeline.length)
		
		assert_equal(false, task1.start)
		assert_equal(true, task1.running?)
		assert_equal(true, task1.has_track?)
		assert_equal(2, task1.timeline.length)
		
		task1.stop
		assert_equal(false, task1.running?)
		assert_equal(false, task1.has_track?)
		assert_equal(2, task1.timeline.length)
		
		task1.toggle
		assert_equal(true, task1.running?)
		assert_equal(true, task1.has_track?)
		assert_equal(3, task1.timeline.length)
		
		task1.toggle
		assert_equal(false, task1.running?)
		assert_equal(true, task1.has_track?)
		assert_equal(3, task1.timeline.length)
		
		# Track
		assert_equal(true, task1.start)
		
		track1 = Track.new
		track1.description = 'hello world1'
		track2 = Track.new
		track2.description = 'hello world2'
		
		assert_equal(true, task1.start(track1))
		assert_equal(false, task1.start(track1))
		assert_equal(true, task1.start(track2))
	end
	
	def test_to_s
		task1 = Task.new
		assert_equal('', task1.to_s)
		
		task1.name = 'task1'
		assert_equal('task1', task1.to_s)
		
		track1 = Track.new
		track1.description = 'hello world1'
		
		task1.start(track1)
		assert_equal('task1', task1.to_s)
		
		task1.stop
		assert_equal('task1', task1.to_s)
	end
	
	def test_run_time_track
		task1 = Task.new
		
		task1.start
		task1.track.begin_time = Time.parse('1987-02-21 09:58:59')
		assert_equal([24, 3, 2], task1.run_time_track(Time.parse('1987-02-22 10:02:01')))
	end
	
	def test_run_time_total
		task1 = Task.new
		task1.toggle # running
		task1.toggle # paused
		task1.toggle # running
		task1.toggle # paused
		task1.toggle # running
		task1.toggle # paused
		
		timeline = task1.timeline
		timeline[0].begin_time = Time.parse('1986-11-20 01:01:01')
		timeline[0].end_time   = Time.parse('1986-11-20 02:02:02')
		timeline[1].begin_time = Time.parse('1991-07-19 03:03:03')
		timeline[1].end_time   = Time.parse('1991-07-19 04:04:04')
		timeline[2].begin_time = Time.parse('1991-08-24 05:05:05')
		timeline[2].end_time   = Time.parse('1991-08-24 06:06:06')
		assert_equal([3, 3, 3], task1.run_time_total)
		
		task1.toggle
		timeline[3].begin_time = Time.parse('2001-01-01 07:07:07')
		assert_equal([4, 4, 5], task1.run_time_total(Time.parse('2001-01-01 08:08:09')))
	end
end
