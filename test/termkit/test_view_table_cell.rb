#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestCellTableView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_table_view
		view1 = View.new
		
		view2 = CellTableView.new(view1)
		assert_instance_of(CellTableView, view2)
	end
	
end
