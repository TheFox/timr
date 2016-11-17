#!/usr/bin/env ruby

require 'minitest/autorun'
require 'time'
require 'fileutils'
require 'timr'

class TestHelpViewController < MiniTest::Test
	
	include TheFox::TermKit
	include TheFox::Timr
	
	def test_help_view_controller
		controller1 = HelpViewController.new
		
		assert_instance_of(HelpViewController, controller1)
	end
	
	def test_render
		controller1 = HelpViewController.new
		
		rendered = controller1.render
		assert_instance_of(Hash, rendered)
	end
	
	def test_handle_event
		controller1 = HelpViewController.new
		
		event1 = KeyEvent.new
		event1.key = 's'
		
		controller1.handle_event(event1)
	end
	
	def test_handle_event_exception
		controller1 = HelpViewController.new
		
		event1 = KeyEvent.new
		event1.key = 'INVALID'
		
		assert_raises(Exception::UnhandledKeyEventException){ controller1.handle_event(event1) }
		assert_raises(Exception::UnhandledEventException){ controller1.handle_event(nil) }
	end
	
end
