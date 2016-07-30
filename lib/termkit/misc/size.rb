
module TheFox
	module TermKit
		
		class Size
			
			def initialize(width = nil, height = nil)
				@width = width
				@height = height
			end
			
			def width=(width)
				@width = width
			end
			
			def width
				@width
			end
			
			def height=(height)
				@height = height
			end
			
			def height
				@height
			end
			
		end
		
	end
end
