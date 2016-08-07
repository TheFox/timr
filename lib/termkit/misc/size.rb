
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
			
			def to_s
				w_s = @width.nil? ? 'NIL' : @width.to_s
				h_s = @height.nil? ? 'NIL' : @height.to_s
				"#<#{self.class} w=#{w_s} h=#{h_s}>"
			end
			
		end
		
	end
end
