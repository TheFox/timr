#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestSize < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_to_s
		size1 = Size.new
		assert_equal('#<TheFox::TermKit::Size w=NIL h=NIL>', size1.to_s)
		
		size1 = Size.new(24)
		assert_equal('#<TheFox::TermKit::Size w=24 h=NIL>', size1.to_s)
		
		size1 = Size.new(nil, 42)
		assert_equal('#<TheFox::TermKit::Size w=NIL h=42>', size1.to_s)
		
		size1 = Size.new(24, 42)
		assert_equal('#<TheFox::TermKit::Size w=24 h=42>', size1.to_s)
	end
	
end
