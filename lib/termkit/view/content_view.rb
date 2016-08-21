
module TheFox
	module TermKit
		
		class ViewContent
			
			HIDE_CHAR = ' '
			
			def initialize(view, char)
				@view = view
				@char = char[0].clone
				@needs_rendering = true
				@hide = false
			end
			
			def char=(char)
				@char = char
				needs_rendering = true
			end
			
			def char
				@char
			end
			
			def needs_rendering=(needs_rendering = true)
				@needs_rendering = needs_rendering
				
				if needs_rendering
					@view.needs_rendering = true
				end
			end
			
			def needs_rendering?
				@needs_rendering
			end
			
			def hide=(hide)
				@hide = hide
			end
			
			def hide
				@hide
			end
			
			def render
				#puts "ViewContent render h=#{@hide ? 'Y' : '-'} c='#{@char}'"
				@needs_rendering = false
				
				if @hide
					@hide = false
					HIDE_CHAR
				else
					@char
				end
			end
			
			def to_s
				char
			end
			
		end
		
	end
end
