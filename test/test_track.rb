#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'pathname'
require 'timr'

class TestTrack < MiniTest::Test
	
	include TheFox::Timr::Model
	include TheFox::Timr::Error
	
	def test_set_begin_end_datetime
		track1 = Track.new
		
		assert_raises(TrackError) do
			track1.end_datetime = nil
		end
		
		track1.begin_datetime = '2017-01-01 01:00:00'
		
		assert_raises(TrackError) do
			track1.end_datetime = nil # Wrong type.
		end
		
		assert_silent do
			track1.end_datetime = '2017-01-01 02:00:00'
		end
	end
	
	def test_set_begin_end_datetime_same
		track1 = Track.new
		
		track1.begin_datetime = '2017-01-02 01:00:00'
		
		assert_raises(TrackError) do
			track1.end_datetime = '2017-01-01 01:00:00'
		end
		assert_raises(TrackError) do
			track1.end_datetime = '2017-01-02 01:00:00'
		end
		
		track1.end_datetime = '2017-01-03 01:00:00'
		track1.begin_datetime = '2017-01-03 00:00:00'
		
		assert_raises(TrackError) do
			track1.begin_datetime = '2017-01-03 01:00:00'
		end
		assert_raises(TrackError) do
			track1.begin_datetime = '2017-01-03 02:00:00'
		end
	end
	
	def test_set_begin_end_datetime_wrong_type
		track1 = Track.new
		
		assert_raises(TrackError) do
			track1.begin_datetime = Date.new
		end
		assert_raises(TrackError) do
			track1.end_datetime = Date.new
		end
	end
	
	def test_start
		options = {
			:date => '2011-12-13',
			:time => '15:30',
		}
		track1 = Track.new
		track1.start(options)
		
		assert_raises(TrackError) do
			track1.start
		end
	end
	
	# Everything empty
	def test_begin_datetime_empty
		options = {
			:date => nil,
			:time => nil,
		}
		track1 = Track.new
		track1.start(options)
		
		#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track1.begin_datetime)
		assert_equal(Time.now.localtime.strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time empty
	def test_begin_datetime_date_set_string_time_empty
		options = {
			:date => '2011-12-13',
			:time => nil,
		}
		track1 = Track.new
		
		assert_raises(DateTimeHelperError) do
			track1.start(options)
		end
	end
	
	# Date set, Time set Hour
	# def test_begin_datetime_date_set_time_set_hour
	# 	options = {
	# 		:date => '2011-12-13',
	# 		:time => '15',
	# 	}
	# 	track1 = Track.new
	# 	track1.start(options)
		
	# 	#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track1.begin_datetime)
	# 	assert_equal(Time.new(2011, 12, 13, 23, 0, 0, 0).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set, Time set Hour, Minute
	def test_begin_datetime_date_set_time_set_hour_minute
		options = {
			:date => '2011-12-13',
			:time => '15:1',
		}
		track1 = Track.new
		track1.start(options)
		
		# puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track1.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 0).localtime.strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second
	def test_begin_datetime_date_set_time_set_hour_minute_second
		options = {
			:date => '2011-12-13',
			:time => '15:1:2',
		}
		track1 = Track.new
		track1.start(options)
		
		# puts
		# puts "time A: #{track1.begin_datetime.strftime('%F %T %z')}"
		# puts "time B: #{Time.new(2011, 12, 13, 15, 1, 2, '+00:00').localtime.strftime('%F %T %z')}"
		# puts "time C: #{Time.new(2011, 12, 13, 15, 1, 2).localtime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track1.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 2).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set Hour, Minute, Second, Timezone
	def test_begin_datetime_date_set_time_set_hour_minute_second_timezone
		options = {
			:date => '2011-12-13',
			:time => '15:01:02+03:00',
		}
		track1 = Track.new
		track1.start(options)
		
		# puts
		# puts "time A: #{track1.begin_datetime.strftime('%F %T %z')}"
		# puts "time B: #{Time.new(2011, 12, 13, 15, 1, 2, '+03:00').localtime.strftime('%F %T %z')}"
		
		assert_instance_of(Time, track1.begin_datetime)
		assert_equal(Time.new(2011, 12, 13, 15, 1, 2, '+03:00').localtime.strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	end
	
	# Date set, Time set DateTime
	# def test_begin_datetime_date_set_time_set_datetime
	# 	options = {
	# 		:date => '2010-11-12',
	# 		:time => DateTime.parse('2012-12-13 14:15:16 +05:00'),
	# 	}
	# 	track1 = Track.new
	# 	track1.start(options)
		
	# 	#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track1.begin_datetime)
	# 	assert_equal(Time.new(2010, 11, 12, 9, 15, 16, 0).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set, Time set Date
	# def test_begin_datetime_date_set_time_set_date
	# 	options = {
	# 		:date => '2010-11-12',
	# 		:time => Date.parse('2012-12-13'),
	# 	}
	# 	track1 = Track.new
	# 	track1.start(options)
		
	# 	#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
	# 	now = Time.now.utc
		
	# 	assert_instance_of(Time, track1.begin_datetime)
	# 	assert_equal(Time.new(2010, 11, 12, now.hour, now.min, now.sec, 0).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set (DateTime), Time set
	# def test_begin_datetime_date_set_datetime_time_set
	# 	options = {
	# 		:date => DateTime.parse('2011-12-13 18:19:20 +0300'),
	# 		:time => '15:13:14',
	# 	}
	# 	track1 = Track.new
	# 	track1.start(options)
		
	# 	#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
	# 	assert_instance_of(Time, track1.begin_datetime)
	# 	assert_equal(Time.new(2011, 12, 13, 14, 13, 14, 0).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	# end
	
	# Date set (Time), Time set
	# def test_begin_datetime_date_set_time_time_set
	# 	options = {
	# 		:date => Time.parse('18:19:20 +0400'),
	# 		:time => '15:13:14',
	# 	}
	# 	track1 = Track.new
	# 	track1.start(options)
		
	# 	#puts "time: #{track1.begin_datetime.strftime('%F %T %z')}"
		
	# 	today = Date.today
		
	# 	assert_instance_of(Time, track1.begin_datetime)
	# 	assert_equal(Time.new(today.year, today.month, today.day, 14, 13, 14, 0).strftime('%F %T %z'), track1.begin_datetime.strftime('%F %T %z'))
	# end
	
	def test_begin_end_datetime_s
		track1 = Track.new
		assert_equal('---', track1.begin_datetime_s)
		assert_equal('---', track1.end_datetime_s)
		
		track1.begin_datetime = '2017-01-01 01:00:00'
		track1.end_datetime   = '2017-01-01 02:00:00'
		
		from = Time.parse('2017-01-01 00:30:00')
		assert_equal('17-01-01 01:00:00', track1.begin_datetime_s({:format => '%y-%m-%d %T', :from => from}))
		
		from = Time.parse('2017-01-01 01:00:05')
		assert_equal('17-01-01 01:00:05', track1.begin_datetime_s({:format => '%y-%m-%d %T', :from => from}))
		
		
		to = Time.parse('2017-01-01 01:59:00')
		assert_equal('17-01-01 01:59:00', track1.end_datetime_s({:format => '%y-%m-%d %T', :to => to}))
		
		to = Time.parse('2017-01-01 02:05:00')
		assert_equal('17-01-01 02:00:00', track1.end_datetime_s({:format => '%y-%m-%d %T', :to => to}))
	end
	
	def test_message
		options = {
			:message => 'msg1',
		}
		track1 = Track.new
		track1.start(options)
		assert_equal('msg1', track1.message)
		
		options = {
			:message => 'msg2',
		}
		track1.stop(options)
		assert_equal('msg2', track1.message)
	end
	
	def test_duration
		track1 = Track.new
		assert_equal(0, track1.duration.to_i)
		
		track1.begin_datetime = '2017-01-01 01:00:00'
		track1.end_datetime   = '2017-01-01 02:00:00'
		assert_equal(3600, track1.duration.to_i)
		
		# Cut Start
		from = Time.parse('2017-01-01 01:00:05')
		to   = nil
		assert_equal(3595, track1.duration({:from => from, :to => to}).to_i)
		
		# Cut End
		from = nil
		to   = Time.parse('2017-01-01 01:55:00')
		assert_equal(3300, track1.duration({:from => from, :to => to}).to_i)
		
		# Cut Start End
		from = Time.parse('2017-01-01 01:00:05')
		to   = Time.parse('2017-01-01 01:55:00')
		assert_equal(3295, track1.duration({:from => from, :to => to}).to_i)
		
		
		track1.end_datetime   = '2017-03-28 16:00:00 +0000'
		track1.begin_datetime = '2017-03-28 15:00:00 +0000'
		
		from = Time.parse('2017-03-31 22:00:00 +0000')
		to   = Time.parse('2017-04-30 21:59:59 +0000')
		assert_equal(0, track1.duration({:from => from, :to => to}).to_i)
	end
	
	def test_billed_duration
		track1 = Track.new
		track1.begin_datetime = '2017-01-01 01:00:00'
		track1.end_datetime   = '2017-01-01 02:00:00'
		track1.is_billed = true
		
		assert_equal(3600, track1.billed_duration.to_i)
		assert_equal(0, track1.unbilled_duration.to_i)
	end
	
	def test_unbilled_duration
		track1 = Track.new
		track1.begin_datetime = '2017-01-01 01:00:00'
		track1.end_datetime   = '2017-01-01 02:00:00'
		track1.is_billed = false
		
		assert_equal(0, track1.billed_duration.to_i)
		assert_equal(3600, track1.unbilled_duration.to_i)
	end
	
	def test_title_nil
		track1 = Track.new
		assert_nil(track1.title)
	end
	
	def test_title_one_row
		track1 = Track.new
		track1.message = "Hello World"
		assert_equal('Hello World', track1.title)
	end
	
	def test_title_two_rows
		track1 = Track.new
		track1.message = "Hello World\nMy second row."
		assert_equal('Hello World', track1.title)
	end
	
	def test_title_three_rows
		track1 = Track.new
		track1.message = "Hello World\n\nLonger description."
		assert_equal('Hello World', track1.title)
	end
	
	def test_title_max_length
		track1 = Track.new
		track1.message = "Hello World\n\nLonger description."
		
		#             123456789ab
		assert_equal('Hello World', track1.title(12))
		assert_equal('Hello World', track1.title(11))
		assert_equal('Hello World', track1.title(10))
		assert_equal('Hello World', track1.title(9))
		assert_equal('Hello Wo...', track1.title(8))
		# assert_equal('Hello World', track1.title(7))
	end
	
	def test_status
		track11 = Track.new
		assert_equal('-', track11.status.short_status)
		assert_equal(true, track11.status.long_status.length > 5)
		
		track11.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track11.status.short_status)
		assert_equal(true, track11.status.long_status.length > 5)
		
		track11.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track11.status.short_status)
		assert_equal(true, track11.status.long_status.length > 5)
	end
	
	def test_status_paused
		track1 = Track.new
		
		track1.paused = false
		assert_equal('-', track1.status.short_status)
		
		track1.paused = true
		assert_equal('-', track1.status.short_status)
		
		track1.paused = false
		track1.begin_datetime = '2017-03-18 01:02:03'
		assert_equal('R', track1.status.short_status)
		
		track1.paused = true
		assert_equal('R', track1.status.short_status)
		
		track1.paused = false
		track1.end_datetime = '2017-03-18 01:02:04'
		assert_equal('S', track1.status.short_status)
		
		track1.paused = true
		assert_equal('P', track1.status.short_status)
		assert_equal(true, track1.status.long_status.length > 5)
	end
	
	def test_dup
		task1 = Task.new
		
		track1 = Track.new
		track1.task = task1
		track1.message = 'xyz'
		
		track2 = track1.dup
		assert_equal('xyz', track2.message)
		assert_equal(task1, track2.task)
		
		track1.message = '123'
		assert_equal('xyz', track2.message)
	end
	
	def test_remove
		track1 = Track.new
		assert_equal(false, track1.remove)
		
		task1 = Task.new
		
		track1.task = task1
		assert_equal(false, track1.remove)
		
		task1.add_track(track1)
		assert_equal(true, track1.remove)
	end
	
	def test_to_s
		track1 = Track.new
		track1.id = '123456789a'
		
		assert_equal('Track_123456', track1.to_s)
	end
	
	def test_to_h
		track1 = Track.new
		
		hash = track1.to_h
		assert_instance_of(Hash, hash)
	end
	
	def test_to_detailed_str_array
		track1 = Track.new
		
		track1.to_detailed_str # @TODO to_detailed_str test
		track1.to_detailed_array # @TODO to_detailed_array test
	end
	
	def test_create_track_from_hash
		assert_raises(TrackError) do
			Track.create_track_from_hash(1)
		end
		
		hash = Hash.new
		track1 = Track.create_track_from_hash(hash)
		assert_instance_of(Track, track1)
	end
	
	def test_find_track_by_id
		base_path = Pathname.new('/tmp')
		track_id = '1234'
		
		found_track = Track.find_track_by_id(base_path, track_id)
		assert_nil(found_track)
	end
	
	def test_formatted
		track1 = Track.new
		assert_equal('AZ', track1.formatted({:format => 'A%TidZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%mZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%bdtZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%bdZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%btZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%edtZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%edZ'}))
		assert_equal('A0Z', track1.formatted({:format => 'A%dsZ'}))
		assert_equal('AZ', track1.formatted({:format => 'A%dhZ'}))
		
		
		track1 = Track.new
		track1.id = '123456789a'
		track1.message = 'xyz'
		track1.begin_datetime = '2017-01-01 01:03:05'
		track1.end_datetime   = '2017-02-03 02:04:06'
		assert_equal('A123456789aZ', track1.formatted({:format => 'A%idZ'}))
		assert_equal('A123456Z', track1.formatted({:format => 'A%sidZ'}))
		assert_equal('AxyzZ', track1.formatted({:format => 'A%mZ'}))
		
		assert_equal('A2017-01-01 01:03Z', track1.formatted({:format => 'A%bdtZ'}))
		assert_equal('A2017-01-01Z', track1.formatted({:format => 'A%bdZ'}))
		assert_equal('A01:03Z', track1.formatted({:format => 'A%btZ'}))
		
		assert_equal('A2017-02-03 02:04Z', track1.formatted({:format => 'A%edtZ'}))
		assert_equal('A2017-02-03Z', track1.formatted({:format => 'A%edZ'}))
		assert_equal('A02:04Z', track1.formatted({:format => 'A%etZ'}))
		
		assert_equal('A2854861Z', track1.formatted({:format => 'A%dsZ'}))
		assert_equal('A793h 1mZ', track1.formatted({:format => 'A%dhZ'}))
		
		
		task1 = Task.new
		task1.id = '23456789ab'
		
		track1 = Track.new
		track1.task = task1
		track1.id = '123456789a'
		
		assert_equal('A234567Z', track1.formatted({:format => 'A%TsidZ'}))
		assert_equal('A123456Z', track1.formatted({:format => 'A%sidZ'}))
		assert_equal('A234567B123456Z', track1.formatted({:format => 'A%TsidB%sidZ'}))
	end
	
end
