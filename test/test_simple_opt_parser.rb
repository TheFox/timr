#!/usr/bin/env ruby

require 'minitest/autorun'
require 'timr'

class TestSimpleOptParser < MiniTest::Test
	
	def test_only_options
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a', '--all'])
		
		opts = optparser.parse('-a --all')
		assert_equal([['-a'], ['--all']], opts)
		
		opts = optparser.parse('-a --all -a')
		assert_equal([['-a'], ['--all'], ['-a']], opts)
	end
	
	def test_one_arg_value1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 1)
		
		opts = optparser.parse('-a val1')
		assert_equal([['-a', 'val1']], opts)
	end
	
	def test_one_arg_value2
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 2)
		
		opts = optparser.parse('-a val1 val2')
		assert_equal([['-a', 'val1', 'val2']], opts)
	end
	
	def test_two_args_value1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 1)
		optparser.register_option(['-b'], 1)
		
		opts = optparser.parse('-a val1 -b val2')
		assert_equal([['-a', 'val1'], ['-b', 'val2']], opts)
	end
	
	def test_two_args_value2
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 2)
		optparser.register_option(['-b'], 1)
		
		opts = optparser.parse('-a val1 val2 -b val3')
		assert_equal([['-a', 'val1', 'val2'], ['-b', 'val3']], opts)
	end
	
	def test_only_commands
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'])
		
		opts = optparser.parse('cmd1')
		assert_equal([['cmd1']], opts)
		
		opts = optparser.parse('cmd1 cmd2')
		assert_equal([['cmd1'], ['cmd2']], opts)
	end
	
	# Registered Arguments
	#   -a <val>
	# 
	# Actual Input (Space at the end.)
	#   '-a '
	def test_empty_split
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'])
		
		opts = optparser.parse('-a ')
		assert_equal([['-a']], opts)
	end
	
	# Registered Arguments
	#   -a <val>
	# 
	# Actual Input
	#   -a
	def test_expect_value1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 1)
		
		assert_raises ArgumentError do
			optparser.parse('-a')
		end
	end
	
	# Registered Arguments
	#   -a <val>
	#   -b
	# 
	# Actual Input
	#   -a -b
	def test_expect_value2
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 1)
		optparser.register_option(['-b'], 0)
		
		assert_raises ArgumentError do
			optparser.parse('-a -b')
		end
	end
	
	# Registered Arguments
	#   -a
	# 
	# Actual Input
	#   -a -b
	def test_unknown1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		
		opts = optparser.parse('-a -b')
		assert_equal([['-a']], opts)
		assert_equal(['-b'], optparser.unknown_options)
	end
	
	# Registered Arguments
	#   -a
	# 
	# Actual Input
	#   -a -b
	def test_unknown2
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 1)
		
		opts = optparser.parse('-a val1 -b')
		assert_equal([['-a', 'val1']], opts)
		assert_equal(['-b'], optparser.unknown_options)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	# 
	# Actual Input
	#   -ab
	def test_compact1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		
		opts = optparser.parse('-ab')
		assert_equal([['-a'], ['-b']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c
	# 
	# Actual Input
	#   -ab
	def test_compact2a
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 0)
		
		opts = optparser.parse('-ab')
		assert_equal([['-a'], ['-b']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c
	# 
	# Actual Input
	#   -abc
	def test_compact2b
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 0)
		
		opts = optparser.parse('-abc')
		assert_equal([['-a'], ['-b'], ['-c']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c
	# 
	# Actual Input
	#   -ab -c
	def test_compact2c
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 0)
		
		opts = optparser.parse('-ab -c')
		assert_equal([['-a'], ['-b'], ['-c']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c
	# 
	# Actual Input (x unknown)
	#   -abx
	def test_compact2d
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 0)
		
		opts = optparser.parse('-abx')
		assert_equal([['-a'], ['-b']], opts)
		assert_equal(['-x'], optparser.unknown_options)
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c <val>
	# 
	# Actual Input
	#   -abc
	def test_compact3a
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 1)
		
		assert_raises ArgumentError do
			optparser.parse('-abc')
		end
	end
	
	# Registered Arguments
	#   -a
	#   -b
	#   -c <val>
	# 
	# Actual Input
	#   -abc val
	def test_compact3b
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 0)
		optparser.register_option(['-c'], 1)
		
		opts = optparser.parse('-abc val1')
		assert_equal([['-a'], ['-b'], ['-c', 'val1']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   -b <val>
	#   -c
	# 
	# Actual Input
	#   -abc val
	def test_compact3c
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a'], 0)
		optparser.register_option(['-b'], 1)
		optparser.register_option(['-c'], 0)
		
		assert_raises ArgumentError do
			optparser.parse('-abc val1')
		end
	end
	
	# Registered Arguments
	#   -a
	#   --all
	#   -b <val>
	#   -C <val>
	#   -d <val>
	#   --expr <val>
	#   -f <val>
	#   --file <val>
	#   -g
	def test_long
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a', '--all'], 0)
		optparser.register_option(['-b'], 1)
		optparser.register_option(['-C'], 1)
		optparser.register_option(['-d'], 1)
		optparser.register_option(['--expr'], 1)
		optparser.register_option(['-f', '--file'], 1)
		optparser.register_option(['-g'])
		
		opts = optparser.parse('-ab val1 -C val2 -d val3 --expr v,a,l,4 --file val5 -g cmd1 --all cmd2 cmd3')
		# puts "#{opts}"
		assert_equal([['-a'], ['-b', 'val1'], ['-C', 'val2'], ['-d', 'val3'], ['--expr', 'v,a,l,4'], ['--file', 'val5'], ['-g'], ['cmd1'], ['--all'], ['cmd2'], ['cmd3']], opts)
	end
	
	# Registered Arguments
	#   -a
	#   --all
	#   -b <val>
	# 
	# Actual Input
	#   -a -b val
	def test_verify1
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a', '--all'], 0)
		optparser.register_option(['-b'], 1)
		
		opts = [['-a'], ['-b', 'val1']]
		assert_equal(true, optparser.verify(opts))
	end
	
	# Registered Arguments
	#   -a
	#   --all
	#   -b <val>
	# 
	# Actual Input
	#   -a val -b
	def test_verify2
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a', '--all'], 0)
		optparser.register_option(['-b'], 1)
		
		opts = [['-a', 'val1'], ['-b']]
		assert_raises ArgumentError do
			optparser.verify(opts)
		end
	end
	
	# Registered Arguments
	#   -a
	#   --all
	#   -b <val>
	# 
	# Actual Input
	#   -a -b
	def test_verify3
		optparser = TheFox::Timr::SimpleOptParser.new
		optparser.register_option(['-a', '--all'], 0)
		optparser.register_option(['-b'], 1)
		
		opts = [['-a'], ['-b']]
		assert_raises ArgumentError do
			optparser.verify(opts)
		end
	end
	
end
