#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestAppController < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_app_controller
		app1 = App.new
		controller1 = AppController.new(app1)
		assert_kind_of(App, app1)
		assert_kind_of(AppController, controller1)
		
		app1 = UIApp.new
		controller1 = AppController.new(app1)
		assert_kind_of(App, app1)
		assert_kind_of(UIApp, app1)
		assert_kind_of(AppController, controller1)
	end
	
	def test_app_controller_exception
		assert_raises(ArgumentError){ AppController.new(nil) }
		assert_raises(ArgumentError){ AppController.new('INVALID') }
	end
	
end
