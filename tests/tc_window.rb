#!/usr/bin/env ruby

require 'minitest/autorun'
#require 'time'
require 'fileutils'
require 'timr'


class TestWindow < MiniTest::Test
	def test_class_name
		window1 = TheFox::Timr::Window.new
		
		assert_equal('TheFox::Timr::Window', window1.class.to_s)
	end
	
	def test_content_refresh
		window1 = TheFox::Timr::Window.new
		assert_equal(1, window1.content_refreshes)
		
		window1.content_length = 10
		window1.content_refresh
		assert_equal(2, window1.content_refreshes)
		
		window1.content_length = 10
		window1.content_refresh
		assert_equal(2, window1.content_refreshes)
		
		window1.content_length = 20
		window1.content_refresh
		assert_equal(3, window1.content_refreshes)
		
		window1.content_changed
		window1.content_refresh
		assert_equal(4, window1.content_refreshes)
	end
	
	def test_page_refreshes
		window1 = TheFox::Timr::Window.new
		assert_equal(0, window1.page_refreshes)
		
		window1.content_changed
		window1.content_refresh
		window1.page
		assert_equal(1, window1.page_refreshes)
	end
	
	def test_page
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 3
		window1.content_refresh
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal(['LINE 001', 'LINE 002', 'LINE 003'], page)
		assert_equal(3, window1.page_length)
		
		window1.content_length = 4
		window1.content_refresh
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal(['LINE 001', 'LINE 002', 'LINE 003', 'LINE 004'], page)
		assert_equal(4, window1.page_length)
	end
	
	def test_page_object
		window1 = TheFox::Timr::TestWindow.new
		assert_equal(1, window1.cursor)
		
		window1.content_length = 3
		window1.content_refresh
		assert_equal('LINE 001', window1.page_object[0..7])
		
		window1.cursor_next_line
		assert_equal('LINE 002', window1.page_object[0..7])
	end
	
	def test_has_next_page
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 3
		window1.content_refresh
		assert_equal(true, window1.next_page?)
		
		window1.content_length = 30
		assert_equal(false, window1.next_page?)
		
		window1.content_length = 30
		window1.content_refresh
		assert_equal(false, window1.next_page?)
		
		window1.content_length = 40
		assert_equal(false, window1.next_page?)
	end
	
	def test_has_previous_page
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 3
		window1.content_refresh
		assert_equal(false, window1.previous_page?)
		
		window1.content_length = 40
		window1.content_refresh
		assert_equal(false, window1.previous_page?)
	end
	
	def test_jmp_next_previous_page
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 3
		window1.content_refresh
		
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..3).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window1.page_length)
		assert_equal(0, window1.current_line)
		assert_equal(1, window1.cursor)
		
		window1.next_page
		assert_equal(3, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((4..6).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.next_page
		assert_equal(6, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..9).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.content_length = 20
		window1.content_refresh
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..26).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(6, window1.current_line)
		assert_equal(1, window1.cursor)
		
		window1.next_page(1)
		assert_equal(7, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((8..27).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.next_page
		assert_equal(27, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((28..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.previous_page
		assert_equal(7, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((8..27).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.previous_page(1)
		assert_equal(6, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..26).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.next_page
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((27..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(4, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.previous_page(1)
		window1.page
		assert_equal(5, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.first_page
		assert_equal(0, window1.current_line)
		assert_equal(1, window1.cursor)
		
		window1.first_page
		assert_equal(0, window1.current_line)
		assert_equal(1, window1.cursor)
		
		window1.next_page(1)
		assert_equal(1, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..21).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(1, window1.cursor)
		
		window1.last_page
		assert_equal(10, window1.current_line)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((11..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window1.page_length)
		assert_equal(20, window1.cursor)
		
		window1.first_page
		window1.content_length = 6
		window1.content_refresh
		assert_equal(0, window1.current_line)
		assert_equal(1, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(2, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(3, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(4, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(4, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..7).map{ |n| 'LINE %03d' % [n] }, page)
		
		(0..21).each do |n|
			window1.cursor_next_line
		end
		assert_equal(4, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((24..29).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(4, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(5, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(6, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_next_line
		assert_equal(6, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(5, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(4, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(3, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(3, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((24..29).map{ |n| 'LINE %03d' % [n] }, page)
		
		(0..21).each do |n|
			window1.cursor_previous_line
		end
		assert_equal(3, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..7).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(3, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(2, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(1, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window1.cursor_previous_line
		assert_equal(1, window1.cursor)
		page = window1.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		
		window1.content = ['line 1', 'line 2', 'line 3']
		window1.content_refresh
		page = window1.page.map{ |page_item| page_item }
		assert_equal((1..3).map{ |n| 'line %d' % [n] }, page)
	end
	
	def test_cursor_border_top_bottom
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 7
		window1.content_refresh
		assert_equal(1, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		window1.cursor_next_line
		assert_equal(1, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		window1.cursor_next_line
		assert_equal(1, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		window1.cursor_next_line
		assert_equal(1, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		window1.cursor_next_line
		assert_equal(1, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		window1.cursor_next_line
		assert_equal(3, window1.cursor_border_top)
		assert_equal(5, window1.cursor_border_bottom)
		
		21.times.each do
			window1.cursor_next_line
			assert_equal(3, window1.cursor_border_top)
			assert_equal(5, window1.cursor_border_bottom)
		end
		
		2.times.each do
			window1.cursor_next_line
			assert_equal(3, window1.cursor_border_top)
			assert_equal(7, window1.cursor_border_bottom)
		end
	end
	
	def test_cursor_on_inner_range_multiple_pages
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 7
		window1.content_refresh
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(false, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		window1.cursor_next_line
		
		21.times.each do
			window1.cursor_next_line
			assert_equal(false, window1.cursor_on_inner_range?)
		end
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_next_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(false, window1.cursor_on_inner_range?)
		
		21.times.each do
			window1.cursor_previous_line
			assert_equal(false, window1.cursor_on_inner_range?)
		end
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
		
		window1.cursor_previous_line
		assert_equal(true, window1.cursor_on_inner_range?)
	end
	
	def test_cursor_on_inner_range_one_page
		window1 = TheFox::Timr::TestWindow.new
		window1.content_length = 35
		window1.content_refresh
		assert_equal(true, window1.cursor_on_inner_range?)
		
		29.times.each do
			window1.cursor_next_line
			assert_equal(true, window1.cursor_on_inner_range?)
		end
	end
end
