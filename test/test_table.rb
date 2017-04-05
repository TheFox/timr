#!/usr/bin/env ruby

require 'minitest/autorun'
# require 'tmpdir'
# require 'fileutils'
# require 'pathname'
require 'timr'

class TestTable < MiniTest::Test
	
	include TheFox::Timr
	# include TheFox::Timr::Model
	# include TheFox::Timr::Error
	
	def test_table
		options = {
			:headings => [
				{:label => 'A'},
				{:label => 'B'},
			],
		}
		table1 = Table.new(options)
		table1 << ['a', 'b']
		table1.to_s
	end
	
end
