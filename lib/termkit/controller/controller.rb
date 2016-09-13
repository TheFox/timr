
module TheFox
	module TermKit
		
		class Controller
			
			attr_reader :subcontrollers
			
			def initialize
				#puts 'Controller initialize'
				
				@is_active = false
				@subcontrollers = []
			end
			
			def active
				@is_active = true
				
				@subcontrollers.each do |subcontroller|
					subcontroller.active
				end
			end
			
			def inactive
				@is_active = false
				
				@subcontrollers.each do |subcontroller|
					subcontroller.inactive
				end
			end
			
			def is_active?
				@is_active
			end
			
			def handle_event(event)
				#puts "Controller handle_event: #{event.class}"
			end
			
			def add_subcontroller(subcontroller)
				if !subcontroller.is_a?(Controller)
					raise ArgumentError, "Argument is not a Controller -- #{subcontroller.class} given"
				end
				if !@subcontrollers.is_a?(Array)
					raise Exception::ParentClassNotInitializedException, "@subcontrollers is not an Array -- #{@subcontrollers.class} given"
				end
				
				@subcontrollers.push(subcontroller)
			end
			
			def remove_subcontroller(subcontroller)
				@subcontrollers.delete(subcontroller)
			end
			
		end
		
	end
end
