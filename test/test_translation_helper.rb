#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestTranslationHelper < MiniTest::Test
	
	include TheFox::Timr::Helper
	
	def test_pluralize
		assert_equal('1 track', TranslationHelper.pluralize(1, 'track', 'tracks'))
		assert_equal('2 tracks', TranslationHelper.pluralize(2, 'track', 'tracks'))
		assert_equal('0 tracks', TranslationHelper.pluralize(0, 'track', 'tracks'))
		
		assert_equal('1 track', TranslationHelper.pluralize(1, 'track'))
		assert_equal('2 tracks', TranslationHelper.pluralize(2, 'track'))
		assert_equal('0 tracks', TranslationHelper.pluralize(0, 'track'))
	end
	
end
