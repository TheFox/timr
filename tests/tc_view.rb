#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


class TestView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_render_exception
		view1 = View.new
		assert_raises ArgumentError do
			view1.draw_point(?x, ?y)
		end
	end
	
	def test_render
		view1 = View.new
		assert_equal({}, view1.render)
		
		view1 = View.new
		view1.draw_point(Point.new(0, 0), ?x)
		view1.draw_point(Point.new(1, 0), ?y)
		view1.draw_point(Point.new(3, 0), ?z)
		
		view1.draw_point(Point.new(0, 2), ?A)
		view1.draw_point(Point.new(3, 2), ?C)
		view1.draw_point(Point.new(2, 2), ?B)
		
		assert_equal({}, view1.render)
		
		view1.is_visible = true
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
	
	def test_to_s1
		view1 = View.new
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?x)
		view1.draw_point(Point.new(1, 0), ?y)
		view1.draw_point(Point.new(3, 0), ?z)
		
		view1.draw_point(Point.new(1, 1), ?A)
		view1.draw_point(Point.new(4, 1), ?B)
		view1.draw_point(Point.new(5, 1), ?C)
		
		view1.draw_point(Point.new(0, 2), ?1)
		view1.draw_point(Point.new(2, 2), ?2)
		view1.draw_point(Point.new(3, 2), ?3)
		
		view1.draw_point(Point.new(0, 4), ?X)
		view1.draw_point(Point.new(2, 4), ?Y)
		view1.draw_point(Point.new(3, 4), ?Z)
		
		assert_equal("xy z\n A  BC\n1 23\n\nX YZ", view1.to_s)
	end
	
	def test_to_s2
		view1 = View.new
		view1.is_visible = true
		
		view1.draw_point(Point.new(1, 1), ?A)
		view1.draw_point(Point.new(4, 1), ?B)
		view1.draw_point(Point.new(5, 1), ?C)
		
		assert_equal("\n A  BC", view1.to_s)
	end
	
	def test_add_subview_exception
		view1 = View.new
		assert_raises ArgumentError do
			view1.add_subview('STRING IS HERE INVALID')
		end
	end
	
	def test_add_subview
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
	
	def test_render_subview
		view1 = View.new
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		
		view1.draw_point(Point.new(0, 1), ?D)
		view1.draw_point(Point.new(1, 1), ?E)
		view1.draw_point(Point.new(2, 1), ?F)
		view1.draw_point(Point.new(3, 1), ?G)
		view1.draw_point(Point.new(4, 1), ?H)
		view1.draw_point(Point.new(5, 1), ?I)
		
		view2 = View.new
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(6, 1)
		view2.draw_point(Point.new(0, 0), ?X)
		view2.draw_point(Point.new(1, 0), ?Y)
		view2.draw_point(Point.new(2, 0), ?Z)
		view1.add_subview(view2)
		
		assert_equal("ABC\nDEFGHIXYZ", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(7, 1)
		view2.draw_point(Point.new(0, 0), ?x)
		assert_equal("ABC\nDEFGHI xYZ", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(3, 1)
		assert_equal("ABC\nDEFxYZ", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(2, 1)
		assert_equal("ABC\nDExYZI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(1, 1)
		assert_equal("ABC\nDxYZHI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(0, 1)
		assert_equal("ABC\nxYZGHI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(1, 2)
		assert_equal("ABC\nDEFGHI\n xYZ", view1.to_s)
		
		view3 = View.new
		view3.is_visible = true
		view3.position = TheFox::TermKit::Point.new(1, 1)
		view3.draw_point(Point.new(0, 0), ?1)
		view3.draw_point(Point.new(1, 0), ?2)
		view3.draw_point(Point.new(2, 0), ?3)
		view1.add_subview(view3)
		
		assert_equal("ABC\nD123HI\n xYZ", view1.to_s)
	end
	
	def test_render_subview_area1
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(0, 1)
		view2.draw_point(Point.new(0, 0), ?D)
		view2.draw_point(Point.new(1, 0), ?E)
		view2.draw_point(Point.new(2, 0), ?F)
		view2.draw_point(Point.new(3, 0), ?G)
		view2.draw_point(Point.new(4, 0), ?H)
		view2.draw_point(Point.new(5, 0), ?I)
		
		view2.draw_point(Point.new(0, 1), ?E)
		view2.draw_point(Point.new(1, 1), ?F)
		view2.draw_point(Point.new(2, 1), ?G)
		view2.draw_point(Point.new(3, 1), ?H)
		view2.draw_point(Point.new(4, 1), ?I)
		view2.draw_point(Point.new(5, 1), ?J)
		view1.add_subview(view2)
		
		assert_equal("ABC\nDEFGHI\nEFGHIJ", view1.to_s)
		assert_equal("ABC\nDEFGHI\nEFGHIJ", view1.to_s_rect)
		assert_equal("ABC\nDEFGHI\nEFGHIJ", view1.to_s_rect(Rect.new))
		
		assert_equal("ABC", view1.to_s_rect(Rect.new(0, 0, 3, 1)))
		assert_equal("ABC\nDEF", view1.to_s_rect(Rect.new(0, 0, 3, 2)))
		assert_equal("DEF", view1.to_s_rect(Rect.new(0, 1, 3, 1)))
		assert_equal("EF", view1.to_s_rect(Rect.new(1, 1, 2, 1)))
		assert_equal("EFG", view1.to_s_rect(Rect.new(1, 1, 3, 1)))
		assert_equal("F", view1.to_s_rect(Rect.new(2, 1, 1, 1)))
		assert_equal("FGH", view1.to_s_rect(Rect.new(2, 1, 3, 1)))
		assert_equal("FGH\nGHI", view1.to_s_rect(Rect.new(2, 1, 3, 2)))
		
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = TheFox::TermKit::Point.new(5, 1)
		view3.draw_point(Point.new(0, 0), ?J)
		view3.draw_point(Point.new(1, 0), ?K)
		view3.draw_point(Point.new(2, 0), ?L)
		view3.draw_point(Point.new(3, 0), ?M)
		view3.draw_point(Point.new(4, 0), ?N)
		view3.draw_point(Point.new(5, 0), ?O)
		view1.add_subview(view3)
		
		view4 = View.new('view4')
		view4.is_visible = true
		view4.position = TheFox::TermKit::Point.new(1, 0)
		view4.draw_point(Point.new(0, 0), ?X)
		view3.add_subview(view4)
		
		assert_equal("HJXL\nIJ", view1.to_s_rect(Rect.new(4, 1, 4, 2)))
	end
	
	def test_render_subview_area2
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(5, 0), ?D)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(2, 1)
		view2.draw_point(Point.new(0, 0), ?D)
		view2.draw_point(Point.new(1, 0), ?E)
		view2.draw_point(Point.new(2, 0), ?F)
		view2.draw_point(Point.new(3, 0), ?G)
		view2.draw_point(Point.new(4, 0), ?H)
		view2.draw_point(Point.new(5, 0), ?I)
		
		view2.draw_point(Point.new(0, 1), ?E)
		view2.draw_point(Point.new(1, 1), ?F)
		view2.draw_point(Point.new(2, 1), ?G)
		view2.draw_point(Point.new(3, 1), ?H)
		view2.draw_point(Point.new(4, 1), ?I)
		view2.draw_point(Point.new(5, 1), ?J)
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = TheFox::TermKit::Point.new(5, 0)
		view3.draw_point(Point.new(1, 0), ?A)
		#view1.add_subview(view3)
		
		
		assert_equal(" D\nFGH\nGHI", view1.to_s_rect(Rect.new(4, 0, 3, 3)))
		assert_equal("FGH\nGHI", view1.to_s_rect(Rect.new(4, 1, 3, 2)))
		
		assert_equal("GHI", view1.to_s_rect(Rect.new(4, 2, 3, 1)))
		assert_equal(" EF", view1.to_s_rect(Rect.new(1, 2, 3, 1)))
		assert_equal("  E", view1.to_s_rect(Rect.new(0, 2, 3, 1)))
		
		assert_equal("ABC\n  D", view1.to_s_rect(Rect.new(0, 0, 3, 2)))
		assert_equal("ABC\n  D\n  E", view1.to_s_rect(Rect.new(0, 0, 3, 3)))
		assert_equal("ABC\n  DE\n  EF", view1.to_s_rect(Rect.new(0, 0, 4, 3)))
		assert_equal("DE\nEF", view1.to_s_rect(Rect.new(2, 1, 2, 2)))
		assert_equal("ABC\n  DEF\n  EFG", view1.to_s_rect(Rect.new(0, 0, 5, 3)))
	end
	
	def test_render_subview_area3
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(5, 0), ?D)
		view1.draw_point(Point.new(4, 1), ?x)
		view1.draw_point(Point.new(5, 1), ?y)
		view1.draw_point(Point.new(6, 1), ?z)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(3, 2)
		view2.draw_point(Point.new(0, 0), ?D)
		view2.draw_point(Point.new(1, 0), ?E)
		view2.draw_point(Point.new(2, 0), ?F)
		view2.draw_point(Point.new(3, 0), ?G)
		view2.draw_point(Point.new(4, 0), ?H)
		view2.draw_point(Point.new(5, 0), ?I)
		
		view2.draw_point(Point.new(0, 1), ?E)
		view2.draw_point(Point.new(1, 1), ?F)
		view2.draw_point(Point.new(2, 1), ?G)
		view2.draw_point(Point.new(3, 1), ?H)
		view2.draw_point(Point.new(4, 1), ?I)
		view2.draw_point(Point.new(5, 1), ?J)
		view1.add_subview(view2)
		
		assert_equal(" DEF\n EFG", view1.to_s_rect(Rect.new(2, 2, 4, 5)))
	end
	
	def test_render_subview_area4
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(3, 1)
		view2.draw_point(Point.new(0, 0), ?D)
		view2.draw_point(Point.new(1, 0), ?E)
		view2.draw_point(Point.new(2, 0), ?F)
		view2.draw_point(Point.new(3, 0), ?G)
		view2.draw_point(Point.new(4, 0), ?H)
		view2.draw_point(Point.new(5, 0), ?I)
		
		view2.draw_point(Point.new(0, 1), ?E)
		view2.draw_point(Point.new(1, 1), ?F)
		view2.draw_point(Point.new(2, 1), ?G)
		view2.draw_point(Point.new(3, 1), ?H)
		view2.draw_point(Point.new(4, 1), ?I)
		view2.draw_point(Point.new(5, 1), ?J)
		view1.add_subview(view2)
		
		assert_equal("ABC", view1.to_s_rect(Rect.new(0, 0, 3, 2)))
	end
	
end
