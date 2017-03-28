#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestProgressBar < MiniTest::Test
	
	include TheFox::Timr
	
	def test_render
		bar1 = ProgressBar.new({:total => 100, :length => 10})
		
		assert_equal('----------', bar1.render)
		assert_equal('#---------', bar1.render(10))
		assert_equal('#####-----', bar1.render(50))
		assert_equal('#########-', bar1.render(90))
		assert_equal('##########', bar1.render(100))
		assert_equal('##########', bar1.render(110))
		
		
		bar1 = ProgressBar.new({:total => 7200, :length => 20})
		assert_equal('--------------------', bar1.render)
		assert_equal('##------------------', bar1.render(720))
		assert_equal('####----------------', bar1.render(1440))
		assert_equal('################----', bar1.render(5760))
		assert_equal('##################--', bar1.render(6480))
		assert_equal('###################-', bar1.render(6840))
	end
	
end
