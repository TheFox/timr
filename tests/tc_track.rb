#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'


class TestTrack < MiniTest::Test
	
	include TheFox::Timr
	
	def test_class_name
		track1 = Track.new
		
		assert_equal('TheFox::Timr::Track', track1.class.to_s)
	end
	
	def test_basic
		track1 = Track.new
		assert_equal(nil, track1.begin_time)
		assert_equal(nil, track1.end_time)
	end
	
	def test_description
		track1 = Track.new
		assert_equal(nil, track1.description)
		
		track1.description = 'hello world1'
		
		track2 = Track.new
		assert_equal(nil, track2.description)
		
		track2.parent = track1
		assert_equal(nil, track2.description)
		
		track1.description = 'hello world2'
		assert_equal(nil, track2.description)
	end
	
	def test_diff
		track1 = Track.new
		assert_equal(0, track1.diff)
		
		track1.begin_time = Time.parse('1986-04-08 13:37:02')
		track1.end_time   = Time.parse('1986-04-08 13:38:01')
		assert_equal(59, track1.diff)
		assert_equal(Fixnum, track1.diff.class)
		
		track1.begin_time = Time.parse('2015-01-16 23:00:00')
		track1.end_time   = Time.parse('2015-06-04 15:30:01')
		assert_equal(11979001, track1.diff)
		assert_equal(Fixnum, track1.diff.class)
	end
	
	def test_name
		task1 = Task.new
		task1.name = 'task1'
		
		track1 = Track.new
		track1.description = 'hello world1'
		
		task1.start(track1)
		assert_equal('hello world1', track1.name)
		
		track1.task = task1
		assert_equal('task1: hello world1', track1.name)
		
		task1.stop
		assert_equal('task1: hello world1', track1.name)
	end
	
	def test_to_h
		track1 = Track.new
		
		h = track1.to_h
		assert_equal(false, h['id'].nil?)
		assert_equal(nil, h['e'])
		assert_equal(nil, h['d'])
		assert_equal(nil, h['p'])
		
		track1.begin_time = Time.parse('1990-02-21 09:45')
		h = track1.to_h
		assert_equal('1990-02-21T08:45:00+0000', h['b'])
		assert_equal(nil, h['e'])
		
		track1.begin_time = Time.parse('1989-10-19 12:59')
		track1.end_time   = Time.parse('2012-12-14 20:45')
		track1.description = 'hello world1'
		h = track1.to_h
		assert_equal('1989-10-19T11:59:00+0000', h['b'])
		assert_equal('2012-12-14T19:45:00+0000', h['e'])
		assert_equal('hello world1', h['d'])
		
		track1.begin_time = Time.parse('2013-11-23 23:00')
		track1.end_time   = Time.parse('2013-11-24 09:00')
		track1.description = 'hello world2'
		h = track1.to_h
		assert_equal('2013-11-23T22:00:00+0000', h['b'])
		assert_equal('2013-11-24T08:00:00+0000', h['e'])
		assert_equal('hello world2', h['d'])
	end
	
	def test_to_list_s
		track1 = Track.new
		track1.begin_time = Time.parse('1990-08-29 12:34:56')
		assert_equal('1990-08-29 12:34 - xx:xx               ', track1.to_list_s)
		
		task1 = Task.new
		task1.name = 'task1'
		track1 = Track.new
		track1.begin_time = Time.parse('1990-08-29 12:34:56')
		track1.task = task1
		assert_equal('1990-08-29 12:34 - xx:xx               task1', track1.to_list_s)
		
		track1.begin_time = Time.parse('1987-06-11 12:00:00')
		track1.end_time   = Time.parse('1987-06-12 23:00:00')
		assert_equal('1987-06-11 12:00 - 23:00 1987-06-12    task1', track1.to_list_s)
		
		track1.description = 'hello world'
		assert_equal('1987-06-11 12:00 - 23:00 1987-06-12    task1: hello world', track1.to_list_s)
	end
	
	def test_from_h
		track1 = Track.from_h(nil, {})
		assert_equal(nil, track1.begin_time)
		assert_equal(nil, track1.end_time)
		
		track1 = Track.from_h(nil, {
			'id' => 'abc',
			'b' => '1986-06-18 12:34:56+0000',
			'e' => '2014-11-11 19:05:12+0000',
			'd' => 'hello world',
			'p' => '123',
		})
		assert_equal('abc', track1.id)
		assert_equal('1986-06-18 14:34:56', track1.begin_time.strftime('%Y-%m-%d %H:%M:%S'))
		assert_equal('2014-11-11 20:05:12',   track1.end_time.strftime('%Y-%m-%d %H:%M:%S'))
		assert_equal('hello world', track1.description)
		assert_equal(nil, track1.parent)
		assert_equal('123', track1.parent_id)
	end
end
