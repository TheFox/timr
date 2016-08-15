#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


class TestViewTable < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_render
		header1 = TheFox::TermKit::TextView.new('--HEADER A--')
		
		view1 = TableView.new('table_view1')
		view1.is_visible = true
		view1.header_cell_view = header1
		view1.table_data = ['zeile A', 'zeile B', "zeile Ca-\nzeile Cb-", 'zeile D-']
		
		#puts view1.to_s
		assert_equal("--HEADER A--\nzeile A\nzeile B\nzeile Ca-\nzeile Cb-\nzeile D-", view1.to_s)
	end
	
	def test_size
		header1 = TheFox::TermKit::TextView.new('--HEADER A--')
		
		view1 = TableView.new('table_view1')
		view1.is_visible = true
		view1.header_cell_view = header1
		view1.table_data = ['zeile A', 'zeile B', "zeile Ca-\nzeile Cb-", 'zeile D-']
		
		view1.size = Size.new(nil, 4)
		assert_equal("--HEADER A--\nzeile A\nzeile B\nzeile Ca-", view1.to_s)
		
		view1.size = Size.new(7, nil)
		assert_equal("--HEADE\nzeile A\nzeile B\nzeile C\nzeile C\nzeile D", view1.to_s)
	end
	
	def test_cursor_position
		header1 = TheFox::TermKit::TextView.new("--HEADER A--\n--HEADER B--")
		
		view1 = TableView.new('table_view1')
		view1.is_visible = true
		view1.header_cell_view = header1
		view1.table_data = [
			'zeile A.',
			'zeile B.',
			"zeile Ca.\nzeile Cbbbbb.",
			'zeile D.',
			'zeile Ee',
			'zeile F',
			"zeile Ga.\nzeile Gb.\nzeile Gc.",
			'zeile H.',
			'zeile I.',
			'zeile J.',
		]
		
		view1.size = Size.new(nil, 6)
		
		assert_equal(1, view1.cursor_position)
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 1
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 2
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 3
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 4
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 5
		assert_equal("--HEADER A--\n--HEADER B--\nzeile B.\nzeile Ca.\nzeile Cbbbbb.\nzeile D.", view1.to_s)
		
		view1.cursor_position = 6
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ca.\nzeile Cbbbbb.\nzeile D.\nzeile Ee", view1.to_s)
		
		view1.cursor_position = 7
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Cbbbbb.\nzeile D.\nzeile Ee\nzeile F", view1.to_s)
		
		view1.cursor_position = 8
		assert_equal("--HEADER A--\n--HEADER B--\nzeile D.\nzeile Ee\nzeile F\nzeile Ga.", view1.to_s)
		
		view1.cursor_position = 9
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ee\nzeile F\nzeile Ga.\nzeile Gb.", view1.to_s)
		
		view1.cursor_position = 10
		assert_equal("--HEADER A--\n--HEADER B--\nzeile F\nzeile Ga.\nzeile Gb.\nzeile Gc.", view1.to_s)
		
		view1.cursor_position = 11
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ga.\nzeile Gb.\nzeile Gc.\nzeile H.", view1.to_s)
		
		view1.cursor_position = 12
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gb.\nzeile Gc.\nzeile H.\nzeile I.", view1.to_s)
		
		view1.cursor_position = 13
		assert_equal(13, view1.cursor_position)
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 14
		assert_equal(13, view1.cursor_position)
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 15
		assert_equal(13, view1.cursor_position)
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 12
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 11
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 10
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gc.\nzeile H.\nzeile I.\nzeile J.", view1.to_s)
		
		view1.cursor_position = 9
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gb.\nzeile Gc.\nzeile H.\nzeile I.", view1.to_s)
		
		view1.cursor_position = 10
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gb.\nzeile Gc.\nzeile H.\nzeile I.", view1.to_s)
		
		view1.cursor_position = 9
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Gb.\nzeile Gc.\nzeile H.\nzeile I.", view1.to_s)
		
		view1.cursor_position = 8
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ga.\nzeile Gb.\nzeile Gc.\nzeile H.", view1.to_s)
		
		view1.cursor_position = 7
		assert_equal("--HEADER A--\n--HEADER B--\nzeile F\nzeile Ga.\nzeile Gb.\nzeile Gc.", view1.to_s)
		
		view1.cursor_position = 6
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ee\nzeile F\nzeile Ga.\nzeile Gb.", view1.to_s)
		
		view1.cursor_position = 5
		assert_equal("--HEADER A--\n--HEADER B--\nzeile D.\nzeile Ee\nzeile F\nzeile Ga.", view1.to_s)
		
		view1.cursor_position = 4
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Cbbbbb.\nzeile D.\nzeile Ee\nzeile F", view1.to_s)
		
		view1.cursor_position = 3
		assert_equal("--HEADER A--\n--HEADER B--\nzeile Ca.\nzeile Cbbbbb.\nzeile D.\nzeile Ee", view1.to_s)
		
		view1.cursor_position = 2
		assert_equal("--HEADER A--\n--HEADER B--\nzeile B.\nzeile Ca.\nzeile Cbbbbb.\nzeile D.", view1.to_s)
		
		view1.cursor_position = 1
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		view1.cursor_position = 0
		assert_equal(1, view1.cursor_position)
		assert_equal("--HEADER A--\n--HEADER B--\nzeile A.\nzeile B.\nzeile Ca.\nzeile Cbbbbb.", view1.to_s)
		
		#puts view1.to_s
		#puts
		
	end
	
end
