#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestDuration < MiniTest::Test
	
	include TheFox::Timr
	
	def test_man_days
		duration1 = Duration.new(7200 + 1800)
		assert_equal('2h 30m', duration1.to_man_days)
		
		duration1 = Duration.new(8 * 3600 + 4 * 3600)
		assert_equal('1d 4h', duration1.to_man_days)
		
		duration1 = Duration.new(7 * 8 * 3600 + 4 * 3600)
		assert_equal('1w 2d 4h', duration1.to_man_days)
	end
	
end
