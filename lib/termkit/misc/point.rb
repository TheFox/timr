
module TheFox
	module TermKit
		
		class Point
			
			attr_accessor :x
			attr_accessor :y
			
			def initialize(x = nil, y = nil)
				case x
				when Array
					y = x[1]
					x = x[0]
				when Hash
					y = if x['y']
							x['y']
						elsif x[:y]
							x[:y]
						end
					
					x = if x['x']
							x['x']
						elsif x[:x]
							x[:x]
						end
				end
				
				@x = x
				@y = y
			end
			
			def to_s
				x_s = x.nil? ? 'NIL' : x
				y_s = y.nil? ? 'NIL' : y
				"#<#{self.class} x=#{x_s} y=#{y_s}>"
			end
			
		end
		
	end
end
