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
	
	def test_x
		rect1 = Rect.new
		assert_nil(rect1.x)
		
		rect1 = Rect.new(42)
		assert_equal(42, rect1.x)
	end
	
	def test_y
		rect1 = Rect.new
		assert_nil(rect1.y)
		
		rect1 = Rect.new(nil, 42)
		assert_equal(42, rect1.y)
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
	
	def test_width
		rect1 = Rect.new
		assert_nil(rect1.width)
		
		rect1 = Rect.new(nil, nil, 42)
		assert_equal(42, rect1.width)
	end
	
	def test_height
		rect1 = Rect.new
		assert_nil(rect1.height)
		
		rect1 = Rect.new(nil, nil, nil, 42)
		assert_equal(42, rect1.height)
	end
	
	def test_to_s
		rect1 = Rect.new
		assert_equal('#<TheFox::TermKit::Rect NIL:NIL NIL:NIL>', rect1.to_s)
		
		rect1 = Rect.new(7)
		assert_equal('#<TheFox::TermKit::Rect 7:NIL NIL:NIL>', rect1.to_s)
		
		rect1 = Rect.new(7, 21)
		assert_equal('#<TheFox::TermKit::Rect 7:21 NIL:NIL>', rect1.to_s)
		
		rect1 = Rect.new(7, 21, 24)
		assert_equal('#<TheFox::TermKit::Rect 7:21 24:NIL>', rect1.to_s)
		
		rect1 = Rect.new(7, 21, 24, 42)
		assert_equal('#<TheFox::TermKit::Rect 7:21 24:42>', rect1.to_s)
	end
	
end
