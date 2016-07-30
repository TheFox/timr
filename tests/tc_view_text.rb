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
		rendered = view1.render
		
		rendered_row = rendered[0]
		assert_equal('hello world', rendered_row[0].content)
		
		view1.text = "hello world\n LINE2"
		
		rendered = view1.render
		rendered_row = rendered[0]
		assert_equal('hello world', rendered_row[0].content)
		rendered_row = rendered[1]
		assert_equal(' LINE2', rendered_row[0].content)
	end
	
end
