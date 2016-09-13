#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestParentClassNotInitializedException < MiniTest::Test
	
	include TheFox::TermKit::Exception
	
	def test_exception_initialized_not_class_parent
		assert_raises(ParentClassNotInitializedException){ raise ParentClassNotInitializedException, 'Foo Bar' }
	end
	
end
