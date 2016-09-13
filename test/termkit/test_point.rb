#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestPoint < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_to_s
		point1 = Point.new
		assert_equal('#<TheFox::TermKit::Point nil:nil>', point1.to_s)
		
		point1 = Point.new(1)
		assert_equal('#<TheFox::TermKit::Point 1:nil>', point1.to_s)
		
		point1 = Point.new(nil, 1)
		assert_equal('#<TheFox::TermKit::Point nil:1>', point1.to_s)
		
		point1 = Point.new(1, 2)
		assert_equal('#<TheFox::TermKit::Point 1:2>', point1.to_s)
	end
	
end
