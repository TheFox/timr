#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestCursesApp < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_curses_app
		app1 = CursesApp.new
		assert_instance_of(CursesApp, app1)
	end
	
end
