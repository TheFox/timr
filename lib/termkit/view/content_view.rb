
module TheFox
	module TermKit
		
		class ViewContent
			
			def initialize(view, char)
				@view = view
				@char = char[0].clone
			end
			
			def char=(char)
				@char = char
			end
			
			def char
				@char
			end
			
			def to_s
				char
			end
			
		end
		
	end
end
