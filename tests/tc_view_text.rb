#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestTextView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_render_exception
		view1 = TextView.new
		assert_raises ArgumentError do
			view1.text = nil
		end
		
		assert_raises ArgumentError do
			view1.text = []
		end
	end
	
	def test_render
		view1 = TextView.new('hello world')
		view1.is_visible = true
		
		assert_equal('hello world', view1.to_s)
		
		view1.text = "hello world\n LINE2"
		assert_equal("hello world\n LINE2", view1.to_s)
	end
	
end
