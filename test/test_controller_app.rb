#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestAppController < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_initialize
		assert_raises ArgumentError do
			AppController.new(nil)
		end
		
		assert_raises ArgumentError do
			AppController.new('STRING IS HERE INVALID')
		end
		
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
	
end
