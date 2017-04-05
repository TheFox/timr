#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestStack < MiniTest::Test
	
	include TheFox::Timr::Model
	include TheFox::Timr::Error
	
	def test_stack
		stack1 = Stack.new
	end
	
	def test_current_track
		stack1 = Stack.new
		stack1 << 1
		
		assert_equal(1, stack1.current_track)
	end
	
	def test_start_stop
		stack1 = Stack.new
		assert_equal(false, stack1.has_changed)
		assert_equal(0, stack1.tracks.count)
		
		assert_raises(StackError) do
			stack1.start(1)
		end
		
		stack1.start(Track.new)
		assert_equal(true, stack1.has_changed)
		assert_equal(1, stack1.tracks.count)
		
		stack1.start(Track.new)
		assert_equal(true, stack1.has_changed)
		assert_equal(1, stack1.tracks.count)
		
		stack1.stop
		assert_equal(0, stack1.tracks.count)
	end
	
	def test_push_remove_tos
		stack1 = Stack.new
		assert_equal(false, stack1.has_changed)
		assert_equal(0, stack1.tracks.count)
		assert_equal('Stack: 0 tracks', stack1.to_s)
		
		assert_raises(StackError) do
			stack1.push(1)
		end
		assert_raises(StackError) do
			stack1.remove(1)
		end
		
		track1 = Track.new
		track2 = Track.new
		# track3 = Track.new
		
		stack1.push(track1)
		assert_equal(true, stack1.has_changed)
		assert_equal(1, stack1.tracks.count)
		assert_equal('Stack: 1 track', stack1.to_s)
		
		stack1.push(track2)
		assert_equal(true, stack1.has_changed)
		assert_equal(2, stack1.tracks.count)
		assert_equal('Stack: 2 tracks', stack1.to_s)
		
		stack1.stop
		assert_equal(1, stack1.tracks.count)
		assert_equal('Stack: 1 track', stack1.to_s)
		
		stack1.remove(track2)
		assert_equal(1, stack1.tracks.count)
		assert_equal('Stack: 1 track', stack1.to_s)
		
		stack1.remove(track1)
		assert_equal(0, stack1.tracks.count)
		assert_equal('Stack: 0 tracks', stack1.to_s)
	end
	
end
