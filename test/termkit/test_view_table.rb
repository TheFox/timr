#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestTableView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_table_view
		view1 = TableView.new
		assert_instance_of(TableView, view1)
	end
	
	def test_render
		
	end
	
end
