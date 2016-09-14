#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestPoint < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_point
		point1 = Point.new
		assert_same(nil, point1.x)
		assert_same(nil, point1.y)
		
		point1 = Point.new(21, 42)
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new([21, 42])
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new({'x' => 21, 'y' => 42})
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new({:x => 21, :y => 42})
		assert_same(21, point1.x)
		assert_same(42, point1.y)
	end
	
	def test_to_s
		point1 = Point.new
		assert_equal('#<TheFox::TermKit::Point x=NIL y=NIL>', point1.to_s)
		
		point1 = Point.new(1)
		assert_equal('#<TheFox::TermKit::Point x=1 y=NIL>', point1.to_s)
		
		point1 = Point.new(nil, 1)
		assert_equal('#<TheFox::TermKit::Point x=NIL y=1>', point1.to_s)
		
		point1 = Point.new(1, 2)
		assert_equal('#<TheFox::TermKit::Point x=1 y=2>', point1.to_s)
	end
	
end
