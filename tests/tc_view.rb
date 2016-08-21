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
	
	def test_render1
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
			assert_equal('x', rendered_row[0])
			assert_equal('y', rendered_row[1])
			assert_equal('z', rendered_row[3])
			
			rendered_row = rendered[2]
			assert_equal('A', rendered_row[0])
			assert_equal('B', rendered_row[2])
			assert_equal('C', rendered_row[3])
		end
	end
	
	def test_render2
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
		
		
		rendered = view1.render
		
		rendered_row = rendered[0]
		assert_equal('x', rendered_row[0])
		assert_equal('y', rendered_row[1])
		assert_equal('z', rendered_row[3])
		
		rendered_row = rendered[1]
		assert_equal('A', rendered_row[1])
		assert_equal('B', rendered_row[4])
		assert_equal('C', rendered_row[5])
		
		rendered_row = rendered[2]
		assert_equal('1', rendered_row[0])
		assert_equal('2', rendered_row[2])
		assert_equal('3', rendered_row[3])
		
		rendered_row = rendered[3]
		assert_equal(nil, rendered_row)
		
		rendered_row = rendered[4]
		assert_equal('X', rendered_row[0])
		assert_equal('Y', rendered_row[2])
		assert_equal('Z', rendered_row[3])
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
		view1.draw_point(Point.new(5, 1), ?I)
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		
		view1.draw_point(Point.new(0, 1), ?D)
		view1.draw_point(Point.new(1, 1), ?E)
		view1.draw_point(Point.new(2, 1), ?F)
		view1.draw_point(Point.new(3, 1), ?G)
		view1.draw_point(Point.new(4, 1), ?H)
		
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
		assert_equal("ABC\nDEFGHIxYZ", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(3, 1)
		assert_equal("ABC\nDEFxYZ", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(2, 1)
		assert_equal("ABC\nDExYZI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(1, 1)
		assert_equal("ABC\nDxYZHI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(0, 1)
		assert_equal("ABC\nxYZGHI", view1.to_s)
		
		view2.position = TheFox::TermKit::Point.new(1, 2)
		assert_equal("ABC\nDEFGHI\nxYZ", view1.to_s)
		
		view3 = View.new
		view3.is_visible = true
		view3.position = TheFox::TermKit::Point.new(1, 1)
		view3.draw_point(Point.new(0, 0), ?1)
		view3.draw_point(Point.new(1, 0), ?2)
		view3.draw_point(Point.new(2, 0), ?3)
		view1.add_subview(view3)
		
		assert_equal("ABC\nD123HI\nxYZ", view1.to_s)
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
		
		
		assert_equal("D\nFGH\nGHI", view1.to_s_rect(Rect.new(4, 0, 3, 3)))
		assert_equal("FGH\nGHI", view1.to_s_rect(Rect.new(4, 1, 3, 2)))
		
		assert_equal('GHI', view1.to_s_rect(Rect.new(4, 2, 3, 1)))
		assert_equal('EF', view1.to_s_rect(Rect.new(1, 2, 3, 1)))
		assert_equal('E', view1.to_s_rect(Rect.new(0, 2, 3, 1)))
		
		assert_equal("ABC\nD", view1.to_s_rect(Rect.new(0, 0, 3, 2)))
		assert_equal("ABC\nD\nE", view1.to_s_rect(Rect.new(0, 0, 3, 3)))
		assert_equal("ABC\nDE\nEF", view1.to_s_rect(Rect.new(0, 0, 4, 3)))
		assert_equal("DE\nEF", view1.to_s_rect(Rect.new(2, 1, 2, 2)))
		assert_equal("ABC\nDEF\nEFG", view1.to_s_rect(Rect.new(0, 0, 5, 3)))
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
		
		assert_equal("DEF\nEFG", view1.to_s_rect(Rect.new(2, 2, 4, 5)))
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
		
		assert_equal('ABC', view1.to_s_rect(Rect.new(0, 0, 3, 2)))
	end
	
	def test_render_size1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		view1.draw_point(Point.new(0, 1), ?B)
		view1.draw_point(Point.new(1, 1), ?C)
		view1.draw_point(Point.new(2, 1), ?D)
		view1.draw_point(Point.new(3, 1), ?E)
		
		view1.draw_point(Point.new(0, 2), ?C)
		view1.draw_point(Point.new(1, 2), ?D)
		view1.draw_point(Point.new(2, 2), ?E)
		view1.draw_point(Point.new(3, 2), ?F)
		
		view1.draw_point(Point.new(0, 3), ?D)
		view1.draw_point(Point.new(1, 3), ?E)
		view1.draw_point(Point.new(2, 3), ?F)
		view1.draw_point(Point.new(3, 3), ?G)
		
		assert_equal("ABCD\nBCDE\nCDEF\nDEFG", view1.to_s)
		
		view1.size = TheFox::TermKit::Size.new(3, 2)
		assert_equal("ABC\nBCD", view1.to_s)
	end
	
	def test_render_size2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		view1.draw_point(Point.new(0, 1), ?B)
		view1.draw_point(Point.new(1, 1), ?C)
		view1.draw_point(Point.new(2, 1), ?D)
		view1.draw_point(Point.new(3, 1), ?E)
		
		assert_equal("ABCD\nBCDE", view1.to_s)
		
		view1.size = TheFox::TermKit::Size.new(3, 2)
		assert_equal("ABC\nBCD", view1.to_s)
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(3, 1)
		view2.draw_point(Point.new(0, 0), ?A)
		view2.draw_point(Point.new(1, 0), ?B)
		view2.draw_point(Point.new(2, 0), ?C)
		view2.draw_point(Point.new(3, 0), ?D)
		view2.draw_point(Point.new(0, 1), ?B)
		view2.draw_point(Point.new(1, 1), ?C)
		view2.draw_point(Point.new(2, 1), ?D)
		view2.draw_point(Point.new(3, 1), ?E)
		view1.add_subview(view2)
		
		
		view1.size = TheFox::TermKit::Size.new(nil, 2)
		assert_equal("ABCD\nBCDABCD", view1.to_s)
		
		view1.size = TheFox::TermKit::Size.new(5, nil)
		assert_equal("ABCD\nBCDAB\nBC", view1.to_s)
	end
	
	def test_height1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		assert_equal(1, view1.height)
		
		view1.draw_point(Point.new(0, 1), ?B)
		view1.draw_point(Point.new(1, 1), ?C)
		view1.draw_point(Point.new(2, 1), ?D)
		view1.draw_point(Point.new(3, 1), ?E)
		assert_equal(2, view1.height)
		
		view1.draw_point(Point.new(0, 2), ?C)
		view1.draw_point(Point.new(1, 2), ?D)
		view1.draw_point(Point.new(2, 2), ?E)
		view1.draw_point(Point.new(3, 2), ?F)
		assert_equal(3, view1.height)
		
		view1.draw_point(Point.new(0, 3), ?D)
		view1.draw_point(Point.new(1, 3), ?E)
		view1.draw_point(Point.new(2, 3), ?F)
		view1.draw_point(Point.new(3, 3), ?G)
		assert_equal(4, view1.height)
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(3, 1)
		view2.draw_point(Point.new(0, 0), ?A)
		view2.draw_point(Point.new(1, 0), ?B)
		view2.draw_point(Point.new(2, 0), ?C)
		view2.draw_point(Point.new(3, 0), ?D)
		view1.add_subview(view2)
		
		assert_equal(4, view1.height)
		
		view2.position = TheFox::TermKit::Point.new(3, 5)
		assert_equal(6, view1.height)
	end
	
	def test_height2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 2), ?A)
		view1.draw_point(Point.new(1, 2), ?B)
		view1.draw_point(Point.new(2, 2), ?C)
		view1.draw_point(Point.new(3, 2), ?D)
		assert_equal(1, view1.height)
		
		view1.draw_point(Point.new(0, 3), ?B)
		view1.draw_point(Point.new(1, 3), ?C)
		view1.draw_point(Point.new(2, 3), ?D)
		view1.draw_point(Point.new(3, 3), ?E)
		assert_equal(2, view1.height)
		
		view1.draw_point(Point.new(0, 4), ?C)
		view1.draw_point(Point.new(1, 4), ?D)
		view1.draw_point(Point.new(2, 4), ?E)
		view1.draw_point(Point.new(3, 4), ?F)
		assert_equal(3, view1.height)
		
		view1.draw_point(Point.new(0, 5), ?D)
		view1.draw_point(Point.new(1, 5), ?E)
		view1.draw_point(Point.new(2, 5), ?F)
		view1.draw_point(Point.new(3, 5), ?G)
		assert_equal(4, view1.height)
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(3, 1)
		view2.draw_point(Point.new(0, 0), ?A)
		view2.draw_point(Point.new(1, 0), ?B)
		view2.draw_point(Point.new(2, 0), ?C)
		view2.draw_point(Point.new(3, 0), ?D)
		view1.add_subview(view2)
		
		assert_equal(5, view1.height)
	end
	
	def test_redraw0
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		assert_equal('ABCD', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		puts 'draw point'
		view1.draw_point(Point.new(1, 0), ?b)
		assert_equal('b', view1.to_s)
		puts
	end
	
	def test_redraw1
		view1 = View.new('view1')
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		assert_equal('', view1.to_s)
		puts
		
		view1.is_visible = true
		
		assert_equal('ABCD', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		view1.is_visible = false
		assert_equal('    ', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		view1.is_visible = true
		assert_equal('ABCD', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		puts 'draw point'
		view1.draw_point(Point.new(1, 0), ?b)
		assert_equal('b', view1.to_s)
	end
	
	def test_redraw2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		assert_equal('ABCD', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(2, 0)
		view2.draw_point(Point.new(0, 0), ?W)
		view2.draw_point(Point.new(1, 0), ?X)
		view2.draw_point(Point.new(2, 0), ?Y)
		view2.draw_point(Point.new(3, 0), ?Z)
		view1.add_subview(view2)
		
		assert_equal('WXYZ', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
	end
	
	def test_redraw3
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		assert_equal('ABCD', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(2, 0)
		view2.draw_point(Point.new(0, 0), ?W)
		view2.draw_point(Point.new(1, 0), ?X)
		view2.draw_point(Point.new(2, 0), ?Y)
		view2.draw_point(Point.new(3, 0), ?Z)
		view1.add_subview(view2)
		
		assert_equal('WXYZ', view1.to_s)
		puts
		assert_equal('', view1.to_s)
		puts
		
		view2.is_visible = false
		
		# At the first time re-draw with spaces.
		assert_equal('ABCD  ', view1.to_s)
		puts
		
		#assert_equal('', view1.to_s)
		
	end
	
	def test_negative_position
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(-1, -1)
		view2.draw_point(Point.new(0, 0), ?X)
		view2.draw_point(Point.new(1, 0), ?Y)
		view2.draw_point(Point.new(2, 0), ?Z)
		view2.draw_point(Point.new(0, 1), ?W)
		view2.draw_point(Point.new(1, 1), ?X)
		view2.draw_point(Point.new(2, 1), ?Y)
		view1.add_subview(view2)
		
		assert_equal('XYCD', view1.to_s_rect(Rect.new(0, 0)))
	end
	
	def test_offset1
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(1, 1)
		view2.draw_point(Point.new(0, 0), ?X)
		view2.draw_point(Point.new(1, 0), ?Y)
		view2.draw_point(Point.new(2, 0), ?Z)
		view2.draw_point(Point.new(0, 1), ?W)
		view2.draw_point(Point.new(1, 1), ?X)
		view2.draw_point(Point.new(2, 1), ?Y)
		view1.add_subview(view2)
		
		#puts view1.to_s
		
		view2.offset = Point.new(0, 1)
		#puts view1.to_s
		assert_equal("ABCD\nWXY", view1.to_s)
	end
	
	def test_offset2
		view1 = View.new('view1')
		view1.is_visible = true
		view1.draw_point(Point.new(0, 0), ?A)
		view1.draw_point(Point.new(1, 0), ?B)
		view1.draw_point(Point.new(2, 0), ?C)
		view1.draw_point(Point.new(3, 0), ?D)
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = TheFox::TermKit::Point.new(1, 1)
		view2.draw_point(Point.new(0, 0), ?X)
		view2.draw_point(Point.new(1, 0), ?Y)
		view2.draw_point(Point.new(2, 0), ?Z)
		view2.draw_point(Point.new(0, 1), ?W)
		view2.draw_point(Point.new(1, 1), ?X)
		view2.draw_point(Point.new(2, 1), ?Y)
		view1.add_subview(view2)
		
		view2.offset = Point.new(0, 1)
		assert_equal("BC\nWX", view1.to_s_rect(Rect.new(1, 0, 2)))
	end
	
end
