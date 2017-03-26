#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'timr'

class TestTrack < MiniTest::Test
	
	include TheFox::Timr
	include TheFox::Timr::Error
	
	def test_set_begin_end_datetime
		track = Track.new
		
		assert_raises(TrackError) do
			track.end_datetime = nil
		end
		
		track.begin_datetime = '2017-01-01 01:00:00'
		
		assert_raises(TrackError) do
			track.end_datetime = nil # Wrong type.
		end
		
		assert_silent do
			track.end_datetime = '2017-01-01 02:00:00'
		end
	end
	
	def test_set_begin_end_datetime_same
		track = Track.new
		
		track.begin_datetime = '2017-01-02 01:00:00'
		
		assert_raises(TrackError) do
			track.end_datetime = '2017-01-01 01:00:00'
		end
		assert_raises(TrackError) do
			track.end_datetime = '2017-01-02 01:00:00'
		end
		
		track.end_datetime = '2017-01-03 01:00:00'
		track.begin_datetime = '2017-01-03 00:00:00'
		
		assert_raises(TrackError) do
			track.begin_datetime = '2017-01-03 01:00:00'
		end
		assert_raises(TrackError) do
			track.begin_datetime = '2017-01-03 02:00:00'
		end
	end
	
	def test_set_begin_end_datetime_wrong_type
		track = Track.new
		
		assert_raises(TrackError) do
			track.begin_datetime = Date.new
		end
		assert_raises(TrackError) do
			track.end_datetime = Date.new
		end
	end
	
	# Everything empty
	def test_begin_datetime_empty
		options = {
			:date => nil,
			:time => nil,
		}
		track = Track.new
		track.start(options)
		
		#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.now.localtime.strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time empty
	def test_begin_datetime_date_set_string_time_empty
		options = {
			:date => '2011-12-13',
			:time => nil,
		}
		track = Track.new
		
		assert_raises(DateTimeError) do
			track.start(options)
		end
	end
	
	# Date set, Time set Hour
	# def test_begin_datetime_date_set_time_set_hour
	# 	options = {
	# 		:date => '2011-12-13',
	# 		:time => '15',
	# 	}
	# 	track = Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(2011, 12, 13, 23, 0, 0, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set, Time set Hour, Minute
	def test_begin_datetime_date_set_time_set_hour_minute
		options = {
			:date => '2011-12-13',
			:time => '15:1',
		}
		track = Track.new
		track.start(options)
		
		# puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 0).localtime.strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second
	def test_begin_datetime_date_set_time_set_hour_minute_second
		options = {
			:date => '2011-12-13',
			:time => '15:1:2',
		}
		track = Track.new
		track.start(options)
		
		# puts
		# puts "time A: #{track.begin_datetime.strftime('%F %T %z')}"
		# puts "time B: #{Time.new(2011, 12, 13, 15, 1, 2, '+00:00').localtime.strftime('%F %T %z')}"
		# puts "time C: #{Time.new(2011, 12, 13, 15, 1, 2).localtime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 2).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second, Timezone
	def test_begin_datetime_date_set_time_set_hour_minute_second_timezone
		options = {
			:date => '2011-12-13',
			:time => '15:01:02+03:00',
		}
		track = Track.new
		track.start(options)
		
		# puts
		# puts "time A: #{track.begin_datetime.strftime('%F %T %z')}"
		# puts "time B: #{Time.new(2011, 12, 13, 15, 1, 2, '+03:00').localtime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 2, '+03:00').localtime.strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set DateTime
	# def test_begin_datetime_date_set_time_set_datetime
	# 	options = {
	# 		:date => '2010-11-12',
	# 		:time => DateTime.parse('2012-12-13 14:15:16 +05:00'),
	# 	}
	# 	track = Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(2010, 11, 12, 9, 15, 16, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set, Time set Date
	# def test_begin_datetime_date_set_time_set_date
	# 	options = {
	# 		:date => '2010-11-12',
	# 		:time => Date.parse('2012-12-13'),
	# 	}
	# 	track = Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	now = Time.now.utc
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(2010, 11, 12, now.hour, now.min, now.sec, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set (DateTime), Time set
	# def test_begin_datetime_date_set_datetime_time_set
	# 	options = {
	# 		:date => DateTime.parse('2011-12-13 18:19:20 +0300'),
	# 		:time => '15:13:14',
	# 	}
	# 	track = Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(2011, 12, 13, 14, 13, 14, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set (Time), Time set
	# def test_begin_datetime_date_set_time_time_set
	# 	options = {
	# 		:date => Time.parse('18:19:20 +0400'),
	# 		:time => '15:13:14',
	# 	}
	# 	track = Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	today = Date.today
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(today.year, today.month, today.day, 14, 13, 14, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	def test_begin_end_datetime_s
		track = Track.new
		track.begin_datetime = '2017-01-01 01:00:00'
		track.end_datetime   = '2017-01-01 02:00:00'
		
		from = Time.parse('2017-01-01 00:30:00')
		assert_equal('17-01-01 01:00:00', track.begin_datetime_s({:format => '%y-%m-%d %T', :from => from}))
		
		from = Time.parse('2017-01-01 01:00:05')
		assert_equal('17-01-01 01:00:05', track.begin_datetime_s({:format => '%y-%m-%d %T', :from => from}))
		
		
		to = Time.parse('2017-01-01 01:59:00')
		assert_equal('17-01-01 01:59:00', track.end_datetime_s({:format => '%y-%m-%d %T', :to => to}))
		
		to = Time.parse('2017-01-01 02:05:00')
		assert_equal('17-01-01 02:00:00', track.end_datetime_s({:format => '%y-%m-%d %T', :to => to}))
	end
	
	def test_message
		options = {
			:message => 'msg1',
		}
		track = Track.new
		track.start(options)
		assert_equal('msg1', track.message)
		
		options = {
			:message => 'msg2',
		}
		track.stop(options)
		assert_equal('msg2', track.message)
	end
	
	def test_duration
		track = Track.new
		assert_equal(0, track.duration.to_i)
		
		track.begin_datetime = '2017-01-01 01:00:00'
		track.end_datetime   = '2017-01-01 02:00:00'
		assert_equal(3600, track.duration.to_i)
		
		# Cut Start
		from = Time.parse('2017-01-01 01:00:05')
		to   = nil
		assert_equal(3595, track.duration({:from => from, :to => to}).to_i)
		
		# Cut End
		from = nil
		to   = Time.parse('2017-01-01 01:55:00')
		assert_equal(3300, track.duration({:from => from, :to => to}).to_i)
		
		# Cut Start End
		from = Time.parse('2017-01-01 01:00:05')
		to   = Time.parse('2017-01-01 01:55:00')
		assert_equal(3295, track.duration({:from => from, :to => to}).to_i)
	end
	
	def test_title_nil
		track = Track.new
		assert_nil(track.title)
	end
	
	def test_title_one_row
		track = Track.new
		track.message = "Hello World"
		assert_equal('Hello World', track.title)
	end
	
	def test_title_two_rows
		track = Track.new
		track.message = "Hello World\nMy second row."
		assert_equal('Hello World', track.title)
	end
	
	def test_title_three_rows
		track = Track.new
		track.message = "Hello World\n\nLonger description."
		assert_equal('Hello World', track.title)
	end
	
	def test_title_max_length
		track = Track.new
		track.message = "Hello World\n\nLonger description."
		
		#             123456789ab
		assert_equal('Hello World', track.title(12))
		assert_equal('Hello World', track.title(11))
		assert_equal('Hello World', track.title(10))
		assert_equal('Hello World', track.title(9))
		assert_equal('Hello Wo...', track.title(8))
		# assert_equal('Hello World', track.title(7))
	end
	
	def test_status
		track = Track.new
		assert_equal('-', track.status.short_status)
		assert_equal(true, track.status.long_status.length > 5)
		
		track.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track.status.short_status)
		assert_equal(true, track.status.long_status.length > 5)
		
		track.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track.status.short_status)
		assert_equal(true, track.status.long_status.length > 5)
	end
	
	def test_status_paused
		track = Track.new
		
		track.paused = false
		assert_equal('-', track.status.short_status)
		
		track.paused = true
		assert_equal('-', track.status.short_status)
		
		track.paused = false
		track.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track.status.short_status)
		
		track.paused = true
		assert_equal('R', track.status.short_status)
		
		track.paused = false
		track.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track.status.short_status)
		
		track.paused = true
		assert_equal('P', track.status.short_status)
		assert_equal(true, track.status.long_status.length > 5)
	end
	
end
