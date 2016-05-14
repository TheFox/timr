#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'


class TestTrack < MiniTest::Test
	def test_class_name
		track = TheFox::Timr::Track.new
		
		assert_equal('TheFox::Timr::Track', track.class.to_s)
	end
	
	def test_basic
		track = TheFox::Timr::Track.new
		assert_equal(Time.now.to_date, track.begin_time.to_date)
	end
	
	def test_diff
		track = TheFox::Timr::Track.new
		assert_equal(0, track.diff)
		
		track.begin_time = Time.parse('1986-04-08 13:37:02')
		track.end_time   = Time.parse('1986-04-08 13:38:01')
		assert_equal(59, track.diff)
		assert_equal(Fixnum, track.diff.class)
		
		track.begin_time = Time.parse('2015-01-16 23:00:00')
		track.end_time   = Time.parse('2015-06-04 15:30:01')
		assert_equal(11979001, track.diff)
		assert_equal(Fixnum, track.diff.class)
	end
	
	def test_to_h
		track = TheFox::Timr::Track.new(nil, nil, nil)
		h = track.to_h
		assert_equal(nil, h['b'])
		assert_equal(nil, h['e'])
		
		track.begin_time = Time.parse('1990-02-21 09:45')
		h = track.to_h
		assert_equal('1990-02-21T08:45:00+0000', h['b'])
		assert_equal(nil, h['e'])
		
		track.begin_time = Time.parse('1989-10-19 12:59')
		track.end_time   = Time.parse('2012-12-14 20:45')
		h = track.to_h
		assert_equal('1989-10-19T11:59:00+0000', h['b'])
		assert_equal('2012-12-14T19:45:00+0000', h['e'])
		
		track.begin_time = Time.parse('2013-11-23 23:00')
		track.end_time   = Time.parse('2013-11-24 09:00')
		h = track.to_h
		assert_equal('2013-11-23T22:00:00+0000', h['b'])
		assert_equal('2013-11-24T08:00:00+0000', h['e'])
	end
	
	def test_to_list_s
		track = TheFox::Timr::Track.new(nil, Time.parse('1990-08-29 12:34:56'))
		assert_equal('1990-08-29 12:34 - xx:xx               ', track.to_list_s)
		
		task = TheFox::Timr::Task.new
		task.name = 'task1'
		track = TheFox::Timr::Track.new(task, Time.parse('1990-08-29 12:34:56'))
		assert_equal('1990-08-29 12:34 - xx:xx               task1', track.to_list_s)
		
		track.begin_time = Time.parse('1987-06-11 12:00:00')
		track.end_time   = Time.parse('1987-06-12 23:00:00')
		assert_equal('1987-06-11 12:00 - 23:00 1987-06-12    task1', track.to_list_s)
	end
	
	def test_from_h
		track = TheFox::Timr::Track.from_h({})
		assert_equal(nil, track.begin_time)
		assert_equal(nil, track.end_time)
		
		track = TheFox::Timr::Track.from_h({
			'b' => '1986-06-18 12:34:56+0000',
			'e' => '2014-11-11 19:05:12+0000',
		})
		assert_equal('1986-06-18 14:34:56', track.begin_time.strftime('%Y-%m-%d %H:%M:%S'))
		assert_equal('2014-11-11 20:05:12',   track.end_time.strftime('%Y-%m-%d %H:%M:%S'))
	end
end
