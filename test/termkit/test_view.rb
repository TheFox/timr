#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


class TestView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_view
		view1 = View.new
		assert_instance_of(View, view1)
	end
	
	def test_name
		view1 = View.new
		assert_nil(view1.name)
		
		view1 = View.new
		view1.name = 'view1'
		assert_equal('view1', view1.name)
		
		view1 = View.new('view1')
		assert_equal('view1', view1.name)
	end
	
	def test_is_visible
		view1 = View.new
		assert_equal(false, view1.is_visible?)
		
		view1.is_visible = false
		assert_equal(false, view1.is_visible?)
		
		view1.is_visible = true
		assert_equal(true, view1.is_visible?)
		
		view1.is_visible = true
		assert_equal(true, view1.is_visible?)
		
		view1.is_visible = false
		assert_equal(false, view1.is_visible?)
	end
	
	def test_add_subview
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		assert_equal(0, view1.subviews.count)
		
		view1.add_subview(view2)
		assert_equal(1, view1.subviews.count)
		assert_equal(view1, view2.parent_view)
		
		view1.add_subview(view3)
		assert_equal(2, view1.subviews.count)
		assert_equal(view1, view3.parent_view)
		
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
		assert_equal(view1, view4.parent_view)
	end
	
	def test_add_subview_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.add_subview('INVALID') }
	end
	
	def test_remove_subview
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		view1.add_subview(view2)
		view1.add_subview(view3)
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view3))
		assert_equal(2, view1.subviews.count)
		
		assert_nil(view1.remove_subview(view3))
		assert_equal(2, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view2))
		assert_equal(1, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view4))
		assert_equal(0, view1.subviews.count)
	end
	
	def test_remove_subview_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.remove_subview('INVALID') }
	end
	
	def test_draw_point
		
		puts
		puts '-- Simple ----------'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal('A', view1.grid[0][0].char)
		assert_equal('A', view1.grid_cache[0][0].char)
		
		
		puts
		puts '-- Subviews --------'
		
		# Subviews
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		
		puts
		puts '-- Visible false ---'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
		
		
		puts
		puts '-- Visible true ----'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
		
		assert_equal('B', view2.grid[0][0].char)
		assert_equal('B', view2.grid_cache[0][0].char)
		
		view2.is_visible = true
		
		# pp view1.grid_cache[0]
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		view2.is_visible = false
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
		
		puts
		puts '--------------------'
		
		
	end
	
	def test_render
		view1 = View.new('view1')
		
		view1.render
	end
	
end
