#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestViewController < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_view_controller
		controller1 = ViewController.new
		assert_nil(controller1.view)
		
		view1 = View.new
		controller1 = ViewController.new(view1)
		assert_equal(view1, controller1.view)
	end
	
	def test_view_controller_exception
		assert_raises(ArgumentError){ ViewController.new(1) }
		assert_raises(ArgumentError){ ViewController.new('INVALID') }
	end
	
end
