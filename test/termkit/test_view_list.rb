#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestListView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_list_view
		view1 = ListView.new
		assert_instance_of(ListView, view1)
	end
	
end
