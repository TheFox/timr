#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestTextView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_text_view
		view1 = TextView.new
		assert_instance_of(TextView, view1)
	end
	
	def test_set_text
		view1 = TextView.new
		view1.text = 'Foo Bar'
	end
	
	def test_set_text_exception
		view1 = TextView.new
		assert_raises(ArgumentError){ view1.text = nil }
	end
	
end
