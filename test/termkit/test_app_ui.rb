#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

require_relative 'app_ui'


class TestUIApp < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_ui_app
		app1 = Test::UIApp.new
		assert_instance_of(Test::UIApp, app1)
	end
	
	def test_set_app_controller
		app1 = Test::UIApp.new
		controller1 = AppController.new(app1)
		app1.set_app_controller(controller1)
		
		assert_instance_of(AppController, app1.app_controller)
		assert_equal(controller1, app1.app_controller)
		assert_same(controller1, app1.app_controller)
	end
	
	def test_set_app_controller_exception
		app1 = Test::UIApp.new
		
		assert_raises(ArgumentError){ app1.set_app_controller(nil) }
		assert_raises(ArgumentError){ app1.set_app_controller('INVALID') }
	end
	
	def test_set_active_controller
		controller1 = ViewController.new
		controller2 = ViewController.new
		
		app1 = Test::UIApp.new
		
		app1.set_active_controller(controller1)
		assert_instance_of(ViewController, app1.active_controller)
		assert_equal(controller1, app1.active_controller)
		
		app1.set_active_controller(controller2)
		assert_instance_of(ViewController, app1.active_controller)
		assert_equal(controller2, app1.active_controller)
	end
	
	def test_set_active_controller_exception
		app1 = Test::UIApp.new
		assert_raises(ArgumentError){ app1.set_active_controller(nil) }
	end
	
	def test_draw_line
		app1 = Test::UIApp.new
		assert_raises(NotImplementedError){ app1.draw_line(nil, nil) }
	end
	
	def test_draw_point
		app1 = Test::UIApp.new
		assert_raises(NotImplementedError){ app1.draw_point(nil, nil) }
	end
	
	def test_ui_refresh
		app1 = Test::UIApp.new
		assert_raises(NotImplementedError){ app1.ui_refresh }
	end
	
	def test_ui_max_x
		app1 = Test::UIApp.new
		assert_equal(-1, app1.ui_max_x)
	end
	
	def test_ui_max_y
		app1 = Test::UIApp.new
		assert_equal(-1, app1.ui_max_y)
	end
	
	def test_app_will_terminate
		app1 = Test::UIApp.new
		assert_equal(42, app1.terminate)
	end
	
	def test_ui_init
		app1 = Test::UIApp.new
		assert_nil(app1.test_ui_init)
	end
	
	def test_key_down
		app1 = Test::UIApp.new
		
		app1.test_key_down(nil)
	end
	
end
