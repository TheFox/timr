#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'timr'

class TestTask < MiniTest::Test
	
	include TheFox::Timr
	include TheFox::Timr::Model
	include TheFox::Timr::Error
	
	def test_name
		task1 = Task.new
		assert_equal(false, task1.has_changed)
		assert_equal('---', task1.name_s)
		
		task1.name = 'xyz'
		assert_equal('xyz', task1.name)
		assert_equal('xyz', task1.name_s)
		assert_equal(true, task1.has_changed)
		
		task1.name = 'xyz123'
		assert_equal('xyz123', task1.name_s)
		assert_equal('xyz123', task1.name(4))
		assert_equal('xyz...', task1.name(3))
		assert_equal('xy...', task1.name(2))
		assert_equal('x...', task1.name(1))
	end
	
	def test_description
		task1 = Task.new
		assert_equal(false, task1.has_changed)
		task1.description = 'xyz'
		assert_equal(true, task1.has_changed)
	end
	
	def test_add_remove_move_track
		track1 = Track.new
		track2 = Track.new
		assert_nil(track1.task)
		assert_nil(track2.task)
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_equal(task1, track1.task)
		assert_equal(task1, track2.task)
		
		task1.remove_track(track1)
		assert_nil(track1.task)
		
		task2 = Task.new
		
		moved = task1.move_track(track2, task1)
		assert_equal(false, moved)
		
		moved = task1.move_track(track1, task2)
		assert_equal(false, moved)
		
		moved = task1.move_track(track2, task2)
		assert_equal(true, moved)
		assert_equal(task2, track2.task)
		
		track3 = Track.new
		assert_nil(task1.current_track)
		task1.add_track(track3)
		
		track4 = Track.new
		task1.add_track(track4, true)
		assert_equal(track4, task1.current_track)
	end
	
	def test_tracks_status
		track1 = Track.new
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		
		assert_raises(TaskError) do
			task1.tracks({:status => 1})
		end
	end
	
	def test_tracks_from_nil_to_nil
		track1 = Track.new
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		tracks = task1.tracks
		
		assert_equal(3, tracks.count)
	end
	
	# From set, To nil
	def test_tracks_from_set_to_nil
		track1 = Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		
		# After End of Track 3.
		from = Time.parse('2015-06-29 00:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(0, tracks.count)
		
		# From within Track 3.
		from = Time.parse('2015-06-28 15:00:00')
		tracks = task1.tracks({:from => from})
		# pp tracks
		assert_equal(1, tracks.count)
		assert_equal(track3.id, tracks.values.first.id)
		
		# Between Track 2 and Track 3.
		from = Time.parse('2015-06-20 15:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(1, tracks.count)
		assert_equal(track3.id, tracks.values.first.id)
		
		# From within Track 2.
		from = Time.parse('2015-06-15 15:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(2, tracks.count)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# Between Track 1 and Track 2.
		from = Time.parse('2015-06-10 15:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(2, tracks.count)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# From within Track 1.
		from = Time.parse('2015-06-05 15:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# Before Track 1.
		from = Time.parse('2015-06-01 15:00:00')
		tracks = task1.tracks({:from => from})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
	end
	
	# From nil, To set
	def test_tracks_from_nil_to_set
		track1 = Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		
		# Before Track 1.
		to = Time.parse('2015-06-01 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(0, tracks.count)
		
		# To within Track 1.
		to = Time.parse('2015-06-05 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(1, tracks.count)
		assert_equal(track1.id, tracks.values.first.id)
		
		# Between Track 1 and Track 2.
		to = Time.parse('2015-06-10 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(1, tracks.count)
		assert_equal(track1.id, tracks.values.first.id)
		
		# To within Track 2.
		to = Time.parse('2015-06-15 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(2, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		
		# Between Track 2 and Track 3.
		to = Time.parse('2015-06-20 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(2, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		
		# To within Track 3.
		to = Time.parse('2015-06-28 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# After Track 3.
		to = Time.parse('2015-06-30 15:00:00')
		tracks = task1.tracks({:to => to})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
	end
	
	# From set, To set
	def test_tracks_from_set_to_set
		track1 = Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-30 20:00:00'
		
		track2 = Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-02 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-10 10:00:00'
		track3.end_datetime   = '2015-07-01 20:00:00'
		
		track4 = Track.new
		track4.id = 't4'
		track4.begin_datetime = '2015-06-12 10:00:00'
		track4.end_datetime   = '2015-06-20 20:00:00'
		
		track5 = Track.new
		track5.id = 't5'
		track5.begin_datetime = '2015-01-01 10:00:00'
		track5.end_datetime   = '2015-01-01 20:00:00'
		
		track6 = Track.new
		track6.id = 't6'
		track6.begin_datetime = '2015-12-20 10:00:00'
		track6.end_datetime   = '2015-12-20 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		task1.add_track(track4)
		task1.add_track(track5)
		task1.add_track(track6)
		
		
		from = Time.parse('2015-06-08 15:00:00')
		to   = Time.parse('2015-06-22 15:00:00')
		tracks = task1.tracks({:from => from, :to => to})
		assert_equal(4, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		assert_equal(track4.id, tracks['t4'].id)
	end
	
	# From bigger than To
	def test_tracks_to_before_from
		task1 = Task.new
		
		from = Time.parse('2015-06-02 15:00:00')
		to   = Time.parse('2015-06-01 15:00:00')
		
		assert_raises(TaskError) do
			task1.tracks({:from => from, :to => to})
		end
	end
	
	def test_begin_datetime_all_set
		track1 = Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-08 10:00:00'
		track1.end_datetime   = '2015-06-27 20:00:00'
		
		track2 = Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-10 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-20 10:00:00'
		track3.end_datetime   = '2015-06-25 20:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		
		from = Time.parse('2015-06-05 09:00:00')
		to   = Time.parse('2015-06-28 15:00:00')
		options = {:format => '%F %T', :from => from, :to => to}
		assert_equal('2015-06-08 10:00:00', task1.begin_datetime_s(options))
		assert_equal('2015-06-27 20:00:00', task1.end_datetime_s(options))
		
		from = Time.parse('2015-06-09 09:00:00')
		to   = Time.parse('2015-06-26 15:00:00')
		options = {:format => '%F %T', :from => from, :to => to}
		assert_equal('2015-06-09 09:00:00', task1.begin_datetime_s(options))
		assert_equal('2015-06-26 15:00:00', task1.end_datetime_s(options))
	end
	
	def test_begin_datetime_end_nil
		track1 = Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-08 10:00:00'
		
		task1 = Task.new
		task1.add_track(track1)
		
		from = Time.parse('2015-06-05 09:00:00')
		to   = Time.parse('2015-06-28 15:00:00')
		options = {:format => '%F %T', :from => from, :to => to}
		assert_equal('2015-06-08 10:00:00', task1.begin_datetime_s(options))
		# assert_nil(task1.end_datetime_s(options))
		assert_equal('---', task1.end_datetime_s(options))
	end
	
	def test_duration
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 11:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:30:00'
		track2.end_datetime   = '2015-06-01 11:30:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_equal(7200, task1.duration.to_i)
		
		# Cut Start
		from = Time.parse('2015-06-01 10:30:00')
		assert_equal(5400, task1.duration({:from => from, :to => nil}).to_i)
		
		# Cut End
		to = Time.parse('2015-06-01 11:00:15')
		assert_equal(5415, task1.duration({:from => nil, :to => to}).to_i)
		
		# Cut Start End
		from = Time.parse('2015-06-01 10:30:00')
		to   = Time.parse('2015-06-01 11:00:15')
		assert_equal(3615, task1.duration({:from => from, :to => to}).to_i)
	end
	
	def test_billed_unbilled_duration
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 11:00:00'
		track1.is_billed = false
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:30:00'
		track2.end_datetime   = '2015-06-01 11:00:00'
		track2.is_billed = true
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_equal(1800, task1.billed_duration.to_i)
		assert_equal(3600, task1.unbilled_duration.to_i)
	end
	
	def test_estimation
		task1 = Task.new
		
		assert_nil(task1.estimation)
		assert_equal('---', task1.estimation_s)
		
		task1.estimation = '2h 31m'
		
		assert_equal(3600 * 2 + 1800 + 60, task1.estimation.to_i)
		assert_equal('2h 31m', task1.estimation_s)
		
		task1.estimation = '+1h 21s'
		assert_equal(12681, task1.estimation.to_i)
		assert_equal('3h 31m', task1.estimation_s)
		
		task1.estimation = '-21s'
		assert_equal(12660, task1.estimation.to_i)
		assert_equal('3h 31m', task1.estimation_s)
		
		task1.estimation = '-45m'
		assert_equal(9960, task1.estimation.to_i)
		assert_equal('2h 46m', task1.estimation_s)
		
		task1.estimation = 25
		assert_equal(25, task1.estimation.to_i)
		assert_equal('25s', task1.estimation_s)
		
		task1.estimation = Duration.new(3605)
		assert_equal(3605, task1.estimation.to_i)
		assert_equal('1h 5s', task1.estimation_s)
		
		assert_raises(TaskError) do
			task1.estimation = Time.new
		end
	end
	
	def test_hourly_rate
		task1 = Task.new
		task1.hourly_rate = nil
		
		task1.hourly_rate = 1.23
		assert_equal(1.23, task1.hourly_rate)
	end
	
	def test_has_flat_rate
		task1 = Task.new
		assert_equal(false, task1.has_changed)
		
		task1.has_flat_rate = true
		assert_equal(true, task1.has_flat_rate)
		assert_equal(true, task1.has_changed)
	end
	
	def test_consumed_budge
		task1 = Task.new
		assert_equal(0.0, task1.consumed_budge)
		
		task1.hourly_rate = 5
		assert_equal(0.0, task1.consumed_budge)
		
		track1 = Track.new
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		task1.add_track(track1)
		
		assert_equal(50.0, task1.consumed_budge)
	end
	
	def test_estimated_budge
		task1 = Task.new
		assert_equal(0.0, task1.estimated_budge)
		
		task1.hourly_rate = 10
		assert_equal(0.0, task1.estimated_budge)
		
		task1.estimation = '10h'
		assert_equal(100.0, task1.estimated_budge)
	end
	
	def test_loss_budge
		task1 = Task.new
		assert_equal(0.0, task1.loss_budge)
		
		task1.has_flat_rate = true
		assert_equal(0.0, task1.loss_budge)
		
		track1 = Track.new
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 15:00:00'
		task1.add_track(track1)
		
		task1.estimation = '10h'
		assert_equal(0.0, task1.loss_budge)
		
		task1.hourly_rate = 10
		assert_equal(0.0, task1.loss_budge)
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-07 09:00:00'
		track2.end_datetime   = '2015-06-07 18:00:00'
		task1.add_track(track2)
		
		#  10h estimation
		# -14h consumed duration
		#  =4h over estimation
		# *10  hourly_rate
		# =40  loss
		assert_equal(40.0, task1.loss_budge)
	end
	
	def test_remaining_time
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 11:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:30:00'
		track2.end_datetime   = '2015-06-01 11:30:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_nil(task1.remaining_time)
		assert_equal('---', task1.remaining_time_s)
		assert_nil(task1.remaining_time_percent)
		assert_equal('---', task1.remaining_time_percent_s)
		
		task1.estimation = '2h 30m'
		
		assert_equal(1800, task1.remaining_time.to_i)
		assert_equal('30m', task1.remaining_time_s)
		assert_equal(20.0, task1.remaining_time_percent)
		assert_equal('20.0 %', task1.remaining_time_percent_s)
		
		track3 = Track.new
		track3.begin_datetime = '2015-06-01 15:00:00'
		track3.end_datetime   = '2015-06-01 16:00:00'
		
		task1.add_track(track3)
		
		assert_equal(0, task1.remaining_time.to_i)
		# assert_equal('0s', task1.remaining_time_s)
		assert_equal('---', task1.remaining_time_s)
		assert_equal(0.0, task1.remaining_time_percent)
		assert_equal('0.0 %', task1.remaining_time_percent_s)
	end
	
	def test_status_notstarted
		task1 = Task.new
		assert_equal('-', task1.status.short_status)
	end
	
	def test_status_running
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 11:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:30:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_equal('R', task1.status.short_status)
	end
	
	def test_status_stopped
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 11:00:00'
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:30:00'
		track2.end_datetime   = '2015-06-01 11:30:00'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		
		assert_equal('S', task1.status.short_status)
	end
	
	def test_status_unknown
		track1 = Track.new
		
		task1 = Task.new
		task1.add_track(track1)
		
		assert_equal('U', task1.status.short_status)
	end
	
	def test_billed
		track1 = Track.new
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-01 10:00:01'
		track1.is_billed = false
		
		track2 = Track.new
		track2.begin_datetime = '2015-06-01 10:00:00'
		track2.end_datetime   = '2015-06-01 10:00:02'
		track2.is_billed = false
		
		track3 = Track.new
		track3.begin_datetime = '2015-06-01 10:00:00'
		track3.end_datetime   = '2015-06-01 10:00:03'
		track3.is_billed = false
		
		track4 = Track.new
		track4.begin_datetime = '2015-06-01 10:00:00'
		track4.end_datetime   = '2015-06-01 10:00:04'
		track4.is_billed = true
		
		track5 = Track.new
		track5.begin_datetime = '2015-06-01 10:00:00'
		track5.end_datetime   = '2015-06-01 10:00:05'
		track5.is_billed = true
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		task1.add_track(track4)
		task1.add_track(track5)
		
		tracks = task1.tracks
		assert_equal(5, tracks.count)
		
		tracks = task1.tracks({:billed => false})
		assert_equal(3, tracks.count)
		
		tracks = task1.tracks({:billed => true})
		assert_equal(2, tracks.count)
		
		assert_equal(15, task1.duration.to_i)
		assert_equal(9, task1.duration({:billed => true}).to_i)
		assert_equal(6, task1.duration({:billed => false}).to_i)
		
		task1.is_billed = true
		assert_equal(15, task1.duration({:billed => true}).to_i)
		assert_equal(0, task1.duration({:billed => false}).to_i)
		
		task1.is_billed = false
		assert_equal(0, task1.duration({:billed => true}).to_i)
		assert_equal(15, task1.duration({:billed => false}).to_i)
	end
	
	def test_find_track_by_id
		track1 = Track.new
		track1.id = '123456789a'
		
		track2 = Track.new
		track2.id = '123456789b'
		
		track3 = Track.new
		track3.id = '23456789ab'
		
		task1 = Task.new
		task1.add_track(track1)
		task1.add_track(track2)
		task1.add_track(track3)
		
		found_track = task1.find_track_by_id('23') # Track 3
		assert_equal(track3, found_track)
		
		assert_raises(TrackError) do
			task1.find_track_by_id('1234') # Track 1+2
		end
	end
	
	def test_eql
		task1 = Task.new
		task2 = Task.new
		
		assert_equal(true, task1.eql?(task1))
		assert_equal(false, task1.eql?(task2))
		
		assert_raises(TaskError) do
			task1.eql?('1234')
		end
	end
	
	def test_to_s
		task1 = Task.new
		task1.id = '123456789a'
		
		assert_equal('Task_123456', task1.to_s)
	end
	
	def test_to_compact_str_array1
		task1 = Task.new
		task1.id = '123456789a'
		task1.name = 'zyx'
		task1.description = 'xyz'
		task1.estimation = '10h 5m'
		
		assert_equal(['Task: 123456 zyx', 'Description: xyz', 'Estimation: 10h 5m'], task1.to_compact_array)
	end
	
	def test_to_compact_str_array2
		task1 = Task.new
		task1.id = '123456789a'
		task1.foreign_id = 'abc'
		task1.name = 'zyx'
		task1.description = 'xyz'
		task1.estimation = '10h 5m'
		
		assert_equal(['Task: abc zyx', 'Description: xyz', 'Estimation: 10h 5m'], task1.to_compact_array)
	end
	
	def test_to_detailed_str_array1
		task1 = Task.new
		task1.id = '123456789a'
		task1.name = 'zyx'
		task1.description = 'xyz'
		task1.estimation = '10h 5m'
		
		task1.to_detailed_str
		task1.to_detailed_array
		
		#assert_equal(['Task: 123456 zyx', '  Description: xyz', '  Estimation: 10h 5m', '  File path: '], task1.to_detailed_array)
		# @TODO to_detailed_array test
	end
	
	def test_to_detailed_str_array2
		task1 = Task.new
		task1.id = '123456789a'
		task1.foreign_id = 'abc'
		task1.name = 'zyx'
		task1.description = 'xyz'
		task1.estimation = '10h 5m'
		
		task1.to_detailed_str
		task1.to_detailed_array
		
		#assert_equal(['Task: 123456 zyx', '  Description: xyz', '  Estimation: 10h 5m', '  File path: '], task1.to_detailed_array)
		# @TODO to_detailed_array test
	end
	
	def test_create_task_from_hash
		options = {
			:name => 'zyx',
			:description => 'xyz',
			:estimation => '20h 31m',
		}
		task1 = Task.create_task_from_hash(options)
		
		assert_equal('zyx', task1.name)
		assert_equal('xyz', task1.description)
		assert_equal('20h 31m', task1.estimation.to_human)
	end
	
end
