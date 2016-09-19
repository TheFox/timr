#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'


class TestTitleView < MiniTest::Test
	
	include TheFox::Timr
	
	def test_title_view
		view1 = TitleView.new
		assert_instance_of(TitleView, view1)
	end
	
end
