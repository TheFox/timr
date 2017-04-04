#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestStatus < MiniTest::Test
	
	include TheFox::Timr
	
	def test_status
		status1 = Status.new('R')
		assert_equal(?R, status1.short_status)
		assert_equal('running', status1.long_status)
		
		status1 = Status.new(?P)
		assert_equal('paused', status1.to_s)
		
		status1 = Status.new(?U)
		assert_equal('unknown', status1.to_s)
		
		status1 = Status.new('xyz')
		assert_equal('unknown', status1.colorized)
	end
	
end
