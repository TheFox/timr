#!/usr/bin/env ruby



require 'minitest/autorun'
# require 'minitest/reporters'
require 'termkit'
# require 'pp'

#Minitest::Reporters.use!

class TestView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_name
		view1 = View.new
		assert_nil(view1.name)
		
		view1 = View.new
		view1.name = 'view1'
		assert_equal('view1', view1.name)
		
		view1 = View.new('view1')
		assert_equal('view1', view1.name)
	end
	
end
