
module TheFox
	module TermKit
		
		class ViewController < Controller
			
			def initialize(view = nil)
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				super()
				
				@view = view
			end
			
			def view
				@view
			end
			
			def render
				
			end
			
		end
		
	end
end
