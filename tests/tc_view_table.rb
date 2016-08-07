#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


class TestViewTable < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_render
		header1 = TheFox::TermKit::TextView.new('--HEADER A--')
		
		view1 = TableView.new
		view1.is_visible = true
		view1.header_cell_view = header1
		view1.table_data = ['zeile A', 'zeile B', "zeile Ca-\nzeile Cb-", 'zeile D-']
		
		assert_equal("--HEADER A--\nzeile A\nzeile B\nzeile Ca-\nzeile Cb-\nzeile D-", view1.to_s)
	end
	
	def test_size
		header1 = TheFox::TermKit::TextView.new('--HEADER A--')
		
		view1 = TableView.new
		view1.is_visible = true
		view1.header_cell_view = header1
		view1.table_data = ['zeile A', 'zeile B', "zeile Ca-\nzeile Cb-", 'zeile D-']
		
		view1.size = Size.new(nil, 4)
		assert_equal("--HEADER A--\nzeile A\nzeile B\nzeile Ca-", view1.to_s)
		
		view1.size = Size.new(7, nil)
		assert_equal("--HEADE\nzeile A\nzeile B\nzeile C\nzeile C\nzeile D", view1.to_s)
	end
	
end
