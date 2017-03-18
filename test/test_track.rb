#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'timr'

class TestTrack < MiniTest::Test
	
	# Everything empty
	def test_begin_datetime_empty
		options = {
			:date => nil,
			:time => nil,
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.now.utc.strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time empty
	def test_begin_datetime_date_set_string_time_empty
		options = {
			:date => '2011-12-13',
			:time => nil,
		}
		track = TheFox::Timr::Track.new
		
		assert_raises ArgumentError do
			track.start(options)
		end
	end
	
	# Date set, Time set Hour
	# def test_begin_datetime_date_set_time_set_hour
	# 	options = {
	# 		:date => '2011-12-13',
	# 		:time => '15',
	# 	}
	# 	track = TheFox::Timr::Track.new
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
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 14, 1, 0, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second
	def test_begin_datetime_date_set_time_set_hour_minute_second
		options = {
			:date => '2011-12-13',
			:time => '15:1:2',
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 14, 1, 2, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second, Timezone
	def test_begin_datetime_date_set_time_set_hour_minute_second_timezone
		options = {
			:date => '2011-12-13',
			:time => '15:01:02+03:00',
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 12, 1, 2, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set DateTime
	# def test_begin_datetime_date_set_time_set_datetime
	# 	options = {
	# 		:date => '2010-11-12',
	# 		:time => DateTime.parse('2012-12-13 14:15:16 +05:00'),
	# 	}
	# 	track = TheFox::Timr::Track.new
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
	# 	track = TheFox::Timr::Track.new
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
	# 	track = TheFox::Timr::Track.new
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
	# 	track = TheFox::Timr::Track.new
	# 	track.start(options)
		
	# 	#puts "time: #{track.begin_datetime.strftime('%F %T %z')}"
		
	# 	today = Date.today
		
	# 	assert_instance_of(Time, track.begin_datetime)
	# 	assert_equal(Time.new(today.year, today.month, today.day, 14, 13, 14, 0).strftime('%F %T %z'), track.begin_datetime.strftime('%F %T %z'))
	# end
	
	def test_message
		options = {
			:message => 'msg1',
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		assert_equal('msg1', track.message)
		
		options = {
			:message => 'msg2',
		}
		track.stop(options)
		assert_equal('msg2', track.message)
	end
	
	def test_duration_small
		options = {
			:date => '2011-12-13',
			:time => '14:15:16',
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#assert_equal('1:02:03', track.duration_s(Time.new(2011, 12, 13, 15, 17, 19)))
	end
	
	def test_duration_big
		options = {
			:date => '2011-12-13',
			:time => '14:15:16',
		}
		track = TheFox::Timr::Track.new
		track.start(options)
		
		#assert_equal('25:02:03', track.duration_s(Time.new(2011, 12, 14, 15, 17, 19)))
	end
	
	def test_title_nil
		track = TheFox::Timr::Track.new
		assert_nil(track.title)
	end
	
	def test_title_one_row
		track = TheFox::Timr::Track.new
		track.message = "Hello World"
		assert_equal('Hello World', track.title)
	end
	
	def test_title_two_rows
		track = TheFox::Timr::Track.new
		track.message = "Hello World\nMy second row."
		assert_equal('Hello World', track.title)
	end
	
	def test_title_three_rows
		track = TheFox::Timr::Track.new
		track.message = "Hello World\n\nLonger description."
		assert_equal('Hello World', track.title)
	end
	
	def test_title_max_length
		track = TheFox::Timr::Track.new
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
		track = TheFox::Timr::Track.new
		assert_equal('-', track.short_status)
		assert_equal(true, track.long_status.length > 5)
		
		track.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track.short_status)
		assert_equal(true, track.long_status.length > 5)
		
		track.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track.short_status)
		assert_equal(true, track.long_status.length > 5)
	end
	
	def test_status_paused
		track = TheFox::Timr::Track.new
		
		track.paused = false
		assert_equal('-', track.short_status)
		
		track.paused = true
		assert_equal('-', track.short_status)
		
		track.paused = false
		track.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track.short_status)
		
		track.paused = true
		assert_equal('R', track.short_status)
		
		track.paused = false
		track.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track.short_status)
		
		track.paused = true
		assert_equal('P', track.short_status)
		assert_equal(true, track.long_status.length > 5)
	end
	
end
