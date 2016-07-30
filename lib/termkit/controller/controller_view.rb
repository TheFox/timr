
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
				#puts 'AppController initialize'
			end
			
			def active
				super()
				
				#render
			end
			
			def inactive
				super()
				
				
			end
			
			def render
				if is_active? && @view_needs_rendering
					@view_needs_rendering = false
					
					@view.render
				else
					[]
				end
			end
			
		end
		
	end
end
