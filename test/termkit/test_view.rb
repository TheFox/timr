#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


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
	
	def test_add_subview
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		assert_equal(0, view1.subviews.count)
		
		view1.add_subview(view2)
		assert_equal(1, view1.subviews.count)
		
		view1.add_subview(view3)
		assert_equal(2, view1.subviews.count)
		
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
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
	
end
