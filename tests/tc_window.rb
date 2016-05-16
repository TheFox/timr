#!/usr/bin/env ruby

require 'minitest/autorun'
#require 'time'
require 'fileutils'
require 'timr'


class TestWindow < MiniTest::Test
	def test_class_name
		window = TheFox::Timr::Window.new
		
		assert_equal('TheFox::Timr::Window', window.class.to_s)
	end
	
	def test_content_refresh
		window = TheFox::Timr::Window.new
		assert_equal(1, window.content_refreshes)
		
		window.content_length = 10
		window.content_refresh
		assert_equal(2, window.content_refreshes)
		
		window.content_length = 10
		window.content_refresh
		assert_equal(2, window.content_refreshes)
		
		window.content_length = 20
		window.content_refresh
		assert_equal(3, window.content_refreshes)
		
		window.content_changed
		window.content_refresh
		assert_equal(4, window.content_refreshes)
	end
	
	def test_page_refreshes
		window = TheFox::Timr::Window.new
		assert_equal(0, window.page_refreshes)
		
		window.content_changed
		window.content_refresh
		window.page
		assert_equal(1, window.page_refreshes)
	end
	
	def test_page
		window = TheFox::Timr::TestWindow.new
		window.content_length = 3
		window.content_refresh
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal(['LINE 001', 'LINE 002', 'LINE 003'], page)
		assert_equal(3, window.page_length)
		
		window.content_length = 4
		window.content_refresh
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal(['LINE 001', 'LINE 002', 'LINE 003', 'LINE 004'], page)
		assert_equal(4, window.page_length)
	end
	
	def test_page_object
		window = TheFox::Timr::TestWindow.new
		assert_equal(1, window.cursor)
		
		window.content_length = 3
		window.content_refresh
		assert_equal('LINE 001', window.page_object[0..7])
		
		window.cursor_next_line
		assert_equal('LINE 002', window.page_object[0..7])
	end
	
	def test_has_next_page
		window = TheFox::Timr::TestWindow.new
		window.content_length = 3
		window.content_refresh
		assert_equal(true, window.next_page?)
		
		window.content_length = 30
		assert_equal(false, window.next_page?)
		
		window.content_length = 30
		window.content_refresh
		assert_equal(false, window.next_page?)
		
		window.content_length = 40
		assert_equal(false, window.next_page?)
	end
	
	def test_has_previous_page
		window = TheFox::Timr::TestWindow.new
		window.content_length = 3
		window.content_refresh
		assert_equal(false, window.previous_page?)
		
		window.content_length = 40
		window.content_refresh
		assert_equal(false, window.previous_page?)
	end
	
	def test_jmp_next_previous_page
		window = TheFox::Timr::TestWindow.new
		window.content_length = 3
		window.content_refresh
		
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..3).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window.page_length)
		assert_equal(0, window.current_line)
		assert_equal(1, window.cursor)
		
		window.next_page
		assert_equal(3, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((4..6).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window.page_length)
		assert_equal(1, window.cursor)
		
		window.next_page
		assert_equal(6, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..9).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window.page_length)
		assert_equal(1, window.cursor)
		
		window.content_length = 20
		window.content_refresh
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..26).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(6, window.current_line)
		assert_equal(1, window.cursor)
		
		window.next_page(1)
		assert_equal(7, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((8..27).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(1, window.cursor)
		
		window.next_page
		assert_equal(27, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((28..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(3, window.page_length)
		assert_equal(1, window.cursor)
		
		window.previous_page
		assert_equal(7, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((8..27).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(1, window.cursor)
		
		window.previous_page(1)
		assert_equal(6, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((7..26).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(1, window.cursor)
		
		window.next_page
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((27..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(4, window.page_length)
		assert_equal(1, window.cursor)
		
		window.previous_page(1)
		window.page
		assert_equal(5, window.page_length)
		assert_equal(1, window.cursor)
		
		window.first_page
		assert_equal(0, window.current_line)
		assert_equal(1, window.cursor)
		
		window.first_page
		assert_equal(0, window.current_line)
		assert_equal(1, window.cursor)
		
		window.next_page(1)
		assert_equal(1, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..21).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(1, window.cursor)
		
		window.last_page
		assert_equal(10, window.current_line)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((11..30).map{ |n| 'LINE %03d' % [n] }, page)
		assert_equal(20, window.page_length)
		assert_equal(20, window.cursor)
		
		window.first_page
		window.content_length = 6
		window.content_refresh
		assert_equal(0, window.current_line)
		assert_equal(1, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(2, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(3, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(4, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(4, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..7).map{ |n| 'LINE %03d' % [n] }, page)
		
		(0..21).each do |n|
			window.cursor_next_line
		end
		assert_equal(4, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((24..29).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(4, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(5, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(6, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_next_line
		assert_equal(6, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(5, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(4, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(3, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((25..30).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(3, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((24..29).map{ |n| 'LINE %03d' % [n] }, page)
		
		(0..21).each do |n|
			window.cursor_previous_line
		end
		assert_equal(3, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((2..7).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(3, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(2, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(1, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		window.cursor_previous_line
		assert_equal(1, window.cursor)
		page = window.page.map{ |page_item| page_item[0..7] }
		assert_equal((1..6).map{ |n| 'LINE %03d' % [n] }, page)
		
		
		window.content = ['line 1', 'line 2', 'line 3']
		window.content_refresh
		page = window.page.map{ |page_item| page_item }
		assert_equal((1..3).map{ |n| 'line %d' % [n] }, page)
	end
	
	def test_cursor_border_top_bottom
		window = TheFox::Timr::TestWindow.new
		window.content_length = 7
		window.content_refresh
		assert_equal(1, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		window.cursor_next_line
		assert_equal(1, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		window.cursor_next_line
		assert_equal(1, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		window.cursor_next_line
		assert_equal(1, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		window.cursor_next_line
		assert_equal(1, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		window.cursor_next_line
		assert_equal(3, window.cursor_border_top)
		assert_equal(5, window.cursor_border_bottom)
		
		21.times.each do
			window.cursor_next_line
			assert_equal(3, window.cursor_border_top)
			assert_equal(5, window.cursor_border_bottom)
		end
		
		2.times.each do
			window.cursor_next_line
			assert_equal(3, window.cursor_border_top)
			assert_equal(7, window.cursor_border_bottom)
		end
	end
	
	def test_cursor_on_inner_range_multiple_pages
		window = TheFox::Timr::TestWindow.new
		window.content_length = 7
		window.content_refresh
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(false, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		window.cursor_next_line
		
		21.times.each do
			window.cursor_next_line
			assert_equal(false, window.cursor_on_inner_range?)
		end
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_next_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(false, window.cursor_on_inner_range?)
		
		21.times.each do
			window.cursor_previous_line
			assert_equal(false, window.cursor_on_inner_range?)
		end
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
		
		window.cursor_previous_line
		assert_equal(true, window.cursor_on_inner_range?)
	end
	
	def test_cursor_on_inner_range_one_page
		window = TheFox::Timr::TestWindow.new
		window.content_length = 35
		window.content_refresh
		assert_equal(true, window.cursor_on_inner_range?)
		
		29.times.each do
			window.cursor_next_line
			assert_equal(true, window.cursor_on_inner_range?)
		end
	end
end
