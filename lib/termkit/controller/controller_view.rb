
module TheFox
	module TermKit
		
		class ViewController < Controller
			
			def initialize(view)
				if !view.is_a?(View)
					raise "view is of wrong class: #{view.class}"
				end
				
				super()
				
				@view = view
				@view_needs_rendering = false
				#puts 'AppController initialize'
			end
			
			def active
				super()
				
				render_view
			end
			
			def inactive
				super()
				
				
			end
			
			def render_view
				if is_active? # && @view_needs_rendering
					@view_needs_rendering = false
					
					
				end
			end
			
		end
		
	end
end
