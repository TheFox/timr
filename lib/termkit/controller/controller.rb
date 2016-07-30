
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
			
			def handle_event(event)
				#puts "Controller handle_event: #{event.class}"
			end
			
		end
		
	end
end
