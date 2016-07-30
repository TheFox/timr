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
	
	def test_is_subrect_exception
		rect1 = Rect.new(0, 0, 10, 5)
		
		assert_raises ArgumentError do
			rect1.is_subrect?(nil)
		end
		
		assert_raises ArgumentError do
			rect1.is_subrect?([])
		end
	end
	
	def test_is_subrect
		[
			
			[Rect.new(0, 0, 10, 10), Rect.new(0, 0, 10, 10), true],
			[Rect.new(0, 0, 10, 10), Rect.new(0, 0, 5, 5), true],
			[Rect.new(1, 2, 10, 10), Rect.new(0, 0, 5, 5), true],
			[Rect.new(5, 5, 10, 10), Rect.new(5, 5, 1, 1), true],
			
		].each do |set|
			assert_equal(set[2], set[0].is_subrect?(set[1]))
		end
	end
	
	def test_equ_exception
		rect1 = Rect.new(1, 2, 3, 4)
		
		assert_raises ArgumentError do
			rect1 == 21
		end
	end
	
	def test_equ
		[
			[Rect.new(1, 2, 3, 4), Rect.new(1, 2, 3, 4), true],
			
			[Rect.new(1, 2, 3, 4), Rect.new(1, 2, 3, 5), false],
			[Rect.new(1, 2, 3, 4), Rect.new(1, 2, 3), false],
			[Rect.new(1, 2, 3, 4), Rect.new(1, 2), false],
			[Rect.new(1, 2, 3, 4), Rect.new(1), false],
			[Rect.new(1, 2, 3, 4), Rect.new, false],
			
			[Rect.new(1, 2, 3), Rect.new(1, 2, 3, 5), false],
			[Rect.new(1, 2), Rect.new(1, 2, 3), false],
			[Rect.new(1), Rect.new(1, 2), false],
			[Rect.new, Rect.new(1), false],
		].each do |set|
			assert_equal(set[2], set[0] == set[1])
		end
	end
	
	def test_bitwise_and_exception
		rect1 = Rect.new(0, 0, 10, 5)
		
		assert_raises NotImplementedError do
			rect1 & 21
		end
	end
	
	def test_bitwise_and
		# Exact
		assert_equal(Rect.new(0, 0, 10, 5), Rect.new(0, 0, 10, 5) & Rect.new(0, 0, 10, 5))
		assert_equal(Rect.new(1, 2, 3, 4), Rect.new(1, 2, 3, 4) & Rect.new(1, 2, 3, 4))
		
		# Inner Sub Rect
		assert_equal(Rect.new(2, 2, 5, 5), Rect.new(0, 0, 10, 10) & Rect.new(2, 2, 5, 5))
		assert_equal(Rect.new(2, 2, 4, 4), Rect.new(0, 0, 10, 10) & Rect.new(2, 2, 4, 4))
		assert_equal(Rect.new(2, 3, 4, 5), Rect.new(1, 2, 15, 20) & Rect.new(2, 3, 4, 5))
		
		# Out Right
		assert_equal(Rect.new(7, 7, 3, 3), Rect.new(5, 5, 5, 5) & Rect.new(7, 7, 5, 5))
		assert_equal(Rect.new(9, 9, 1, 1), Rect.new(5, 5, 5, 5) & Rect.new(9, 9, 2, 2)) # Edge
		assert_equal(Rect.new(7, 7, 3, 3), Rect.new(5, 5, 5, 5) & Rect.new(7, 7, 5, 3)) # X Out
		assert_equal(Rect.new(7, 7, 3, 3), Rect.new(5, 5, 5, 5) & Rect.new(7, 7, 3, 5)) # Y Out
		
		# Out Left
		assert_equal(Rect.new(5, 5, 3, 3), Rect.new(5, 5, 5, 5) & Rect.new(3, 3, 5, 5))
		assert_equal(Rect.new(5, 5, 1, 1), Rect.new(5, 5, 5, 5) & Rect.new(3, 3, 3, 3)) # Edge
		assert_equal(Rect.new(5, 5, 3, 5), Rect.new(5, 5, 5, 5) & Rect.new(3, 3, 5, 7)) # X Out
		assert_equal(Rect.new(5, 5, 5, 3), Rect.new(5, 5, 5, 5) & Rect.new(3, 3, 7, 5)) # Y Out
		
		# # Oversize
		assert_equal(Rect.new(5, 5, 5, 5), Rect.new(5, 5, 5, 5) & Rect.new(2, 2, 11, 11))
		assert_equal(Rect.new(5, 5, 5, 2), Rect.new(5, 5, 5, 5) & Rect.new(2, 2, 11, 5)) # X
		assert_equal(Rect.new(5, 5, 2, 5), Rect.new(5, 5, 5, 5) & Rect.new(2, 2, 5, 11)) # Y
		
		# # Unspecific End
		assert_equal(Rect.new(5, 5, 5, 5), Rect.new(5, 5, 5, 5) & Rect.new(2, 2))
		assert_equal(Rect.new(5, 5, 5, 2), Rect.new(5, 5, 5, 5) & Rect.new(2, 2, nil, 5)) # width
		assert_equal(Rect.new(5, 5, 2, 5), Rect.new(5, 5, 5, 5) & Rect.new(2, 2, 5, nil)) # height
		
		# Not a Sub Rect
		assert_equal(nil, Rect.new(0, 0, 5, 5) & Rect.new(20, 20, 5, 5))
		assert_equal(nil, Rect.new(5, 5, 5, 5) & Rect.new(20, 5, 5, 5))
		assert_equal(nil, Rect.new(5, 5, 5, 5) & Rect.new(5, 20, 5, 5))
	end
	
	def test_sub_exception
		rect1 = Rect.new(0, 0, 10, 5)
		
		assert_raises NotImplementedError do
			rect1 - 21
		end
	end
	
	def test_sub
		
	end
	
end
