#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestKeyEvent < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_curses_app
		event1 = KeyEvent.new
		assert_instance_of(KeyEvent, event1)
	end
	
	def test_to_s
		event1 = KeyEvent.new
		assert_equal('TheFox::TermKit::KeyEvent', event1.to_s)
		
		event1 = KeyEvent.new
		event1.key = 'A'
		assert_equal('TheFox::TermKit::KeyEvent->65[A]', event1.to_s)
	end
	
end
