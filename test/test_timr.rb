#!/usr/bin/env ruby

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
# require 'pathname'
require 'timr'

class TestTimr < MiniTest::Test
	
	include TheFox::Timr
	# include TheFox::Timr::Model
	# include TheFox::Timr::Error
	
	def setup
		# puts
		# puts 'setup'
		
		@tmpdir = Dir.mktmpdir
		
		# puts "tmpdir: #{@tmpdir}"
		# puts
	end
	
	def teardown
		# puts
		# puts 'teardown'
		
		FileUtils.remove_entry_secure(@tmpdir)
	end
	
	def test_timr
		timr1 = Timr.new(@tmpdir)
		timr1.stack.has_changed = true
		timr1.shutdown
		
		timr2 = Timr.new(@tmpdir)
		timr2.shutdown
	end
	
	def test_to_s
		timr1 = Timr.new(@tmpdir)
		
		assert_equal('Timr', timr1.to_s)
	end
	
end
