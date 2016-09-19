#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'


class TestAppController < MiniTest::Test
	
	include TheFox::TermKit
	include TheFox::Timr
	
	def test_app_controller
		app1 = App.new
		controller1 = AppController.new(app1)
		
		assert_instance_of(AppController, controller1)
	end
	
	def test_handle_event
		app1 = App.new
		controller1 = AppController.new(app1)
		
		event1 = KeyEvent.new
		event1.key = 'w'
		
		controller1.handle_event(event1)
	end
	
	def test_handle_event_exception
		app1 = App.new
		controller1 = AppController.new(app1)
		
		event1 = KeyEvent.new
		event1.key = 'INVALID'
		
		assert_raises(Exception::UnhandledKeyEventException){ controller1.handle_event(event1) }
		assert_raises(Exception::UnhandledEventException){ controller1.handle_event(nil) }
	end
	
end
