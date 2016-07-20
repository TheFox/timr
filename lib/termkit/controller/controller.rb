
module TheFox
	module TermKit
		
		class Controller
			
			def initialize
				#puts 'Controller initialize'
				
				@is_active = false
				#@child_controllers = []
				#@child_views = []
			end
			
			def active
				@is_active = true
			end
			
			def inactive
				@is_active = false
			end
			
			def is_active?
				@is_active
			end
			
			# def add_child_controller(child_controller)
			# 	@child_controllers.push(child_controller)
			# end
			
			# def child_controllers_active
			# 	@child_controllers.each do |child_controller|
			# 		child_controller.active
			# 	end
			# end
			
			# def child_controllers_inactive
			# 	@child_controllers.each do |child_controller|
			# 		child_controller.inactive
			# 	end
			# end
			
			def handle_event(event)
				#puts "Controller handle_event: #{event.class}"
			end
			
		end
		
	end
end
