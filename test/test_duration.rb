#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestDuration < MiniTest::Test
	
	include TheFox::Timr
	include TheFox::Timr::Error
	
	def test_to_smh
		duration1 = Duration.new(7200 + 1800 + 35)
		assert_equal([35, 30, 2], duration1.to_smh)
	end
	
	def test_man_days
		duration1 = Duration.new(7200 + 1800)
		assert_equal('2h 30m', duration1.to_man_days)
		
		duration1 = Duration.new(8 * 3600 + 4 * 3600)
		assert_equal('1d 4h', duration1.to_man_days)
		
		duration1 = Duration.new(7 * 8 * 3600 + 4 * 3600)
		assert_equal('1w 2d 4h', duration1.to_man_days)
	end
	
	def test_addition
		duration1 = Duration.new(10)
		duration2 = Duration.new(3)
		duration3 = duration1 + duration2
		
		assert_instance_of(Duration, duration3)
		assert_equal(13, duration3.to_i)
		
		duration4 = duration3 + 5
		assert_instance_of(Duration, duration4)
		assert_equal(18, duration4.to_i)
		
		assert_raises(DurationError) do
			duration4 + 'xyz'
		end
	end
	
	def test_subtract
		duration1 = Duration.new(10)
		duration2 = Duration.new(3)
		duration3 = duration1 - duration2
		
		assert_instance_of(Duration, duration3)
		assert_equal(7, duration3.to_i)
		
		duration4 = duration3 - 4
		assert_instance_of(Duration, duration4)
		assert_equal(3, duration4.to_i)
		
		duration5 = duration4 - 10
		assert_instance_of(Duration, duration5)
		assert_equal(0, duration5.to_i) # -7
		
		assert_raises(DurationError) do
			duration5 - 'xyz'
		end
	end
	
	def test_lesser
		duration1 = Duration.new(1)
		duration2 = Duration.new(2)
		
		assert_equal(true, duration1 < duration2)
		assert_equal(true, duration1 < 2)
	end
	
	def test_greater
		duration1 = Duration.new(1)
		duration2 = Duration.new(2)
		
		assert_equal(true, duration2 > duration1)
		assert_equal(true, duration2 > 1)
	end
	
	def test_to_s
		duration1 = Duration.new(1)
		assert_equal('1', duration1.to_s)
	end
	
	def test_parse
		duration1 = Duration.parse('-2m 30s')
		assert_equal(150, duration1.to_i)
	end
	
end
