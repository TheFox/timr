#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestStack < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_add_subview
		view1 = View.new
		assert_raises Exception do
			view1.add_subview("hello")
		end
		
		view1 = View.new
		assert_equal(0, view1.subviews.count)
		
		view2 = View.new
		view1.add_subview(view2)
		assert_equal(1, view1.subviews.count)
		
		view3 = View.new
		view1.add_subview(view3)
		assert_equal(2, view1.subviews.count)
		
		view1.remove_subview(view2)
		assert_equal(1, view1.subviews.count)
		
		view1.remove_subview(view3)
		assert_equal(0, view1.subviews.count)
	end
	
	def test_render
		view1 = View.new
		assert_equal({}, view1.render)
		
		view1 = View.new
		assert_raises Exception do
			view1.set_point(?x, ?y)
		end
		
		# xy z
		# A BC
		
		view1.set_point(Point.new(0, 0), ?x)
		view1.set_point(Point.new(1, 0), ?y)
		view1.set_point(Point.new(3, 0), ?z)
		
		view1.set_point(Point.new(0, 2), ?A)
		view1.set_point(Point.new(3, 2), ?C)
		view1.set_point(Point.new(2, 2), ?B)
		
		2.times do
			rendered = view1.render
			
			rendered_row = rendered[0]
			assert_equal("xy", rendered_row[0].content)
			assert_equal(0, rendered_row[0].start_x)
			assert_equal("z", rendered_row[1].content)
			assert_equal(3, rendered_row[1].start_x)
			
			rendered_row = rendered[2]
			assert_equal("A", rendered_row[0].content)
			assert_equal(0, rendered_row[0].start_x)
			assert_equal("BC", rendered_row[1].content)
			assert_equal(2, rendered_row[1].start_x)
		end
	end
	
end
