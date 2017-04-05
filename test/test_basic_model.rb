#!/usr/bin/env ruby

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'pathname'
require 'timr'

class TestBasicModel < MiniTest::Test
	
	include TheFox::Timr::Model
	include TheFox::Timr::Error
	
	# def setup
	# 	puts
	# 	puts 'setup'
		
	# 	@tmpdir = Dir.mktmpdir
		
	# 	puts "tmpdir: #{@tmpdir}"
	# 	puts
	# end
	
	# def teardown
	# 	puts
	# 	puts 'teardown'
		
	# 	FileUtils.remove_entry_secure(@tmpdir)
	# end
	
	def test_basic_model
		model1 = BasicModel.new
		
		assert_kind_of(BasicModel, model1)
		assert_instance_of(BasicModel, model1)
	end
	
	def test_short_id
		model1 = BasicModel.new
		model1.id = '123456789a'
		
		assert_equal('123456', model1.short_id)
	end
	
	def test_load_from_file
		model1 = BasicModel.new
		
		assert_raises(ModelError) do
			model1.load_from_file
		end
	end
	
	def test_save_to_file
		model1 = BasicModel.new
		
		assert_raises(ModelError) do
			model1.save_to_file
		end
	end
	
	def test_delete_file
		model1 = BasicModel.new
		
		assert_raises(ModelError) do
			model1.delete_file
		end
	end
	
	def test_create_path_by_id
		base_path = '/tmp'
		id = '3dd50a2b50eabc84022a23ad2c06d9bb6396f978'
		path = BasicModel.create_path_by_id(base_path, id).to_s
		assert_equal('/tmp/3d/d5/0a/2b50eabc84022a23ad2c06d9bb6396f978.yml', path)
		
		assert_raises(IdError) do
			BasicModel.create_path_by_id(base_path, 1)
		end
		assert_raises(IdError) do
			BasicModel.create_path_by_id(base_path, '12345')
		end
	end
	
	def test_get_id_from_path
		base_path = Pathname.new('/tmp')
		path = Pathname.new('/tmp/3d/d5/0a/2b50eabc84022a23ad2c06d9bb6396f978.yml')
		id = BasicModel.get_id_from_path(base_path, path)
		puts "id: #{id}"
	end
	
	def test_find_file_by_id
		assert_raises(IdError) do
			BasicModel.find_file_by_id('/tmp', 123456)
		end
		assert_raises(IdError) do
			BasicModel.find_file_by_id('/tmp', '123')
		end
		assert_raises(ModelError) do
			BasicModel.find_file_by_id('/tmp', '1234')
		end
	end
	
end
