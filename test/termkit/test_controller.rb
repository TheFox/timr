#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'


class TestAppController < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_controller
		controller1 = Controller.new
		assert_instance_of(Controller, controller1)
	end
	
	def test_active
		controller1 = Controller.new
		controller2 = Controller.new
		controller3 = Controller.new
		controller4 = Controller.new
		
		controller1.add_subcontroller(controller2)
		controller2.add_subcontroller(controller3)
		controller2.add_subcontroller(controller4)
		
		assert_equal(false, controller1.is_active?)
		assert_equal(false, controller2.is_active?)
		assert_equal(false, controller3.is_active?)
		assert_equal(false, controller4.is_active?)
		
		controller1.active
		assert_equal(true, controller1.is_active?)
		assert_equal(true, controller2.is_active?)
		assert_equal(true, controller3.is_active?)
		assert_equal(true, controller4.is_active?)
	end
	
	def test_inactive
		controller1 = Controller.new
		controller2 = Controller.new
		controller3 = Controller.new
		controller4 = Controller.new
		
		controller1.add_subcontroller(controller2)
		controller2.add_subcontroller(controller3)
		controller2.add_subcontroller(controller4)
		
		assert_equal(false, controller1.is_active?)
		assert_equal(false, controller2.is_active?)
		assert_equal(false, controller3.is_active?)
		assert_equal(false, controller4.is_active?)
		
		controller1.active
		assert_equal(true, controller1.is_active?)
		assert_equal(true, controller2.is_active?)
		assert_equal(true, controller3.is_active?)
		assert_equal(true, controller4.is_active?)
		
		controller1.inactive
		assert_equal(false, controller1.is_active?)
		assert_equal(false, controller2.is_active?)
		assert_equal(false, controller3.is_active?)
		assert_equal(false, controller4.is_active?)
	end
	
	def test_is_active
		controller1 = Controller.new
		assert_equal(false, controller1.is_active?)
	end
	
	def test_add_subcontroller
		controller1 = Controller.new
		controller2 = Controller.new
		controller3 = Controller.new
		controller4 = Controller.new
		
		assert_equal(0, controller1.subcontrollers.count)
		
		controller1.add_subcontroller(controller2)
		assert_equal(1, controller1.subcontrollers.count)
		
		controller1.add_subcontroller(controller3)
		assert_equal(2, controller1.subcontrollers.count)
		
		controller1.add_subcontroller(controller4)
		assert_equal(3, controller1.subcontrollers.count)
	end
	
	def test_add_subcontroller_exception
		controller1 = Controller.new
		
		assert_raises(ArgumentError){ controller1.add_subcontroller(nil) }
	end
	
	def test_remove_subcontroller
		controller1 = Controller.new
		controller2 = Controller.new
		controller3 = Controller.new
		controller4 = Controller.new
		
		controller1.add_subcontroller(controller2)
		controller1.add_subcontroller(controller3)
		controller1.add_subcontroller(controller4)
		assert_equal(3, controller1.subcontrollers.count)
		
		assert_equal(controller3, controller1.remove_subcontroller(controller3))
		assert_equal(2, controller1.subcontrollers.count)
		
		assert_equal(controller2, controller1.remove_subcontroller(controller2))
		assert_equal(1, controller1.subcontrollers.count)
		
		assert_equal(controller4, controller1.remove_subcontroller(controller4))
		assert_equal(0, controller1.subcontrollers.count)
	end
	
end
