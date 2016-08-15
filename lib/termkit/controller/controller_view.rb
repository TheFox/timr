
module TheFox
	module TermKit
		
		class ViewController < Controller
			
			def initialize(view = nil)
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				super()
				
				@view = view
				@view_needs_rendering = true
				@subcontrollers = []
				#puts 'AppController initialize'
			end
			
			def view
				@view
			end
			
			def active
				super()
				
				@subcontrollers.each do |subcontroller|
					@subcontroller.active
				end
			end
			
			def inactive
				super()
				
				@subcontrollers.each do |subcontroller|
					@subcontroller.inactive
				end
			end
			
			def render
				if is_active? && @view_needs_rendering
					@view_needs_rendering = false
					
					@view.render
				else
					[]
				end
			end
			
			def add_subcontroller(subcontroller)
				if !subcontroller.is_a?(ViewController)
					raise ArgumentError, "Argument is not a View -- #{subcontroller.class} given"
				end
				if !@subcontrollers.is_a?(Array)
					raise Exception::ParentClassNotInitializedException, "@subcontrollers is not an Array -- #{@subcontrollers.class} given"
				end
				
				@subcontrollers.push(subcontroller)
			end
			
			def remove_subcontroller(subcontroller)
				@subcontrollers.delete(subcontroller)
			end
			
			def subcontrollers
				@subcontrollers
			end
			
		end
		
	end
end
