#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'timr'
require 'pp' # @TODO remove pp

class TestTask < MiniTest::Test
	
	def test_filter_tracks_from_nil_to_nil
		track1 = TheFox::Timr::Track.new
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = TheFox::Timr::Track.new
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = TheFox::Timr::Track.new
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task = TheFox::Timr::Task.new
		task.add_track(track1)
		task.add_track(track2)
		task.add_track(track3)
		tracks = task.tracks
		
		assert_equal(3, tracks.count)
	end
	
	# From set, To nil
	def test_filter_tracks_from_set_to_nil
		track1 = TheFox::Timr::Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = TheFox::Timr::Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = TheFox::Timr::Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task = TheFox::Timr::Task.new
		task.add_track(track1)
		task.add_track(track2)
		task.add_track(track3)
		
		# After End of Track 3.
		from = Time.parse('2015-06-29 00:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(0, tracks.count)
		
		# From within Track 3.
		from = Time.parse('2015-06-28 15:00:00')
		tracks = task.tracks({:from => from})
		# pp tracks
		assert_equal(1, tracks.count)
		assert_equal(track3.id, tracks.values.first.id)
		
		# Between Track 2 and Track 3.
		from = Time.parse('2015-06-20 15:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(1, tracks.count)
		assert_equal(track3.id, tracks.values.first.id)
		
		# From within Track 2.
		from = Time.parse('2015-06-15 15:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(2, tracks.count)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# Between Track 1 and Track 2.
		from = Time.parse('2015-06-10 15:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(2, tracks.count)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# From within Track 1.
		from = Time.parse('2015-06-05 15:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# Before Track 1.
		from = Time.parse('2015-06-01 15:00:00')
		tracks = task.tracks({:from => from})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
	end
	
	# From nil, To set
	def test_filter_tracks_from_nil_to_set
		track1 = TheFox::Timr::Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-05 10:00:00'
		track1.end_datetime   = '2015-06-05 20:00:00'
		
		track2 = TheFox::Timr::Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-15 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = TheFox::Timr::Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-28 10:00:00'
		track3.end_datetime   = '2015-06-28 20:00:00'
		
		task = TheFox::Timr::Task.new
		task.add_track(track1)
		task.add_track(track2)
		task.add_track(track3)
		
		# Before Track 1.
		to = Time.parse('2015-06-01 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(0, tracks.count)
		
		# To within Track 1.
		to = Time.parse('2015-06-05 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(1, tracks.count)
		assert_equal(track1.id, tracks.values.first.id)
		
		# Between Track 1 and Track 2.
		to = Time.parse('2015-06-10 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(1, tracks.count)
		assert_equal(track1.id, tracks.values.first.id)
		
		# To within Track 2.
		to = Time.parse('2015-06-15 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(2, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		
		# Between Track 2 and Track 3.
		to = Time.parse('2015-06-20 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(2, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		
		# To within Track 3.
		to = Time.parse('2015-06-28 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		
		# After Track 3.
		to = Time.parse('2015-06-30 15:00:00')
		tracks = task.tracks({:to => to})
		assert_equal(3, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
	end
	
	# From set, To set
	def test_filter_tracks_from_set_to_set
		track1 = TheFox::Timr::Track.new
		track1.id = 't1'
		track1.begin_datetime = '2015-06-01 10:00:00'
		track1.end_datetime   = '2015-06-30 20:00:00'
		
		track2 = TheFox::Timr::Track.new
		track2.id = 't2'
		track2.begin_datetime = '2015-06-02 10:00:00'
		track2.end_datetime   = '2015-06-15 20:00:00'
		
		track3 = TheFox::Timr::Track.new
		track3.id = 't3'
		track3.begin_datetime = '2015-06-10 10:00:00'
		track3.end_datetime   = '2015-07-01 20:00:00'
		
		track4 = TheFox::Timr::Track.new
		track4.id = 't4'
		track4.begin_datetime = '2015-06-12 10:00:00'
		track4.end_datetime   = '2015-06-20 20:00:00'
		
		track5 = TheFox::Timr::Track.new
		track5.id = 't5'
		track5.begin_datetime = '2015-01-01 10:00:00'
		track5.end_datetime   = '2015-01-01 20:00:00'
		
		track6 = TheFox::Timr::Track.new
		track6.id = 't6'
		track6.begin_datetime = '2015-12-20 10:00:00'
		track6.end_datetime   = '2015-12-20 20:00:00'
		
		task = TheFox::Timr::Task.new
		task.add_track(track1)
		task.add_track(track2)
		task.add_track(track3)
		task.add_track(track4)
		task.add_track(track5)
		task.add_track(track6)
		
		
		from = Time.parse('2015-06-08 15:00:00')
		to   = Time.parse('2015-06-22 15:00:00')
		tracks = task.tracks({:from => from, :to => to})
		assert_equal(4, tracks.count)
		assert_equal(track1.id, tracks['t1'].id)
		assert_equal(track2.id, tracks['t2'].id)
		assert_equal(track3.id, tracks['t3'].id)
		assert_equal(track4.id, tracks['t4'].id)
	end
	
	# From bigger than To
	def test_filter_tracks_to_before_from
		task = TheFox::Timr::Task.new
		
		from = Time.parse('2015-06-02 15:00:00')
		to   = Time.parse('2015-06-01 15:00:00')
		
		assert_raises RangeError do
			task.tracks({:from => from, :to => to})
		end
	end
	
end
