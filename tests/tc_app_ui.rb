#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestUIApp < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_set_app_controller_exception
		app1 = UIApp.new
		
		assert_raises ArgumentError do
			app1.set_app_controller(nil)
		end
		
		assert_raises ArgumentError do
			app1.set_app_controller('STRING IS HERE INVALID')
		end
	end
	
end
