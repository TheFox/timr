#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


class TestRect < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_rect
		rect1 = Rect.new
		assert_equal(true, rect1.has_default_values?)
		
		rect1 = Rect.new
		rect1.size.width = 0
		assert_equal(false, rect1.has_default_values?)
		
		rect1 = Rect.new
		rect1.size.width = 1
		assert_equal(false, rect1.has_default_values?)
		
		rect1 = Rect.new(0, 0, 10, 10)
		assert_equal(false, rect1.has_default_values?)
	end
	
	def test_max
		rect1 = Rect.new
		assert_equal(nil, rect1.x_max)
		assert_equal(nil, rect1.y_max)
		
		rect1 = Rect.new(1, 1)
		assert_equal(nil, rect1.x_max)
		assert_equal(nil, rect1.y_max)
		
		rect1 = Rect.new(1, nil, 3)
		assert_equal(3, rect1.x_max)
		assert_equal(nil, rect1.y_max)
		
		rect1 = Rect.new(1, 2, 3, 4)
		assert_equal(3, rect1.x_max)
		assert_equal(5, rect1.y_max)
		
		rect1 = Rect.new(nil, 5, nil, 6)
		assert_equal(nil, rect1.x_max)
		assert_equal(10, rect1.y_max)
	end
	
end
