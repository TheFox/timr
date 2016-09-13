
module TheFox
	module TermKit
		
		class Point
			
			attr_accessor :x
			attr_accessor :y
			
			def initialize(x = nil, y = nil)
				@x = x
				@y = y
			end
			
			def to_s
				"#<#{self.class} #{x.nil? ? 'nil' : x}:#{y.nil? ? 'nil' : y}>"
			end
			
		end
		
	end
end
