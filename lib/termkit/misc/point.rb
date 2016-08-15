
module TheFox
	module TermKit
		
		class Point
			
			def initialize(x = nil, y = nil)
				@x = x
				@y = y
			end
			
			def x=(x)
				@x = x
			end
			
			def x
				@x
			end
			
			def y=(y)
				@y = y
			end
			
			def y
				@y
			end
			
			def to_s
				#w_s = width.nil? ? 'NIL' : width
				#h_s = height.nil? ? 'NIL' : height
				"#<#{self.class} #{x}:#{y}>"
			end
			
		end
		
	end
end
