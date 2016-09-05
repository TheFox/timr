#!/usr/bin/env ruby

require 'minitest/autorun'
# require 'minitest/reporters'
require 'termkit'
require 'pp'

#Minitest::Reporters.use!

class TestView < MiniTest::Test
	
	include TheFox::TermKit
	
end
