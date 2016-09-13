#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestViewContent < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_to_s
		view1 = View.new
		
		char = 'A'
		
		content1 = ViewContent.new(view1, char)
		assert_equal('A', content1.to_s)
		assert_equal('A', char)
		
		char = 'B'
		assert_equal('A', content1.to_s)
	end
	
end
