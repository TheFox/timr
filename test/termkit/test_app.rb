#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

require_relative 'app'


class TestUIApp < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_app
		app1 = Test::App.new
		assert_instance_of(Test::App, app1)
	end
	
	def test_terminate
		app1 = Test::App.new
		
		assert_equal(42, app1.terminate)
		assert_nil(app1.terminate)
	end
	
end
