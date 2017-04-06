#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestConfig < MiniTest::Test
	
	# include TheFox::Timr
	include TheFox::Timr::Model
	# include TheFox::Timr::Error
	
	def test_config
		# config1 = Config.new
		Config.new # @TODO config test
	end
	
end
