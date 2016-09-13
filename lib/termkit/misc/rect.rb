
module TheFox
	module TermKit
		
		class Rect
			
			attr_accessor :origin
			attr_accessor :size
			
			def initialize(x = nil, y = nil, width = nil, height = nil)
				@origin = Point.new(x, y)
				@size = Size.new(width, height)
			end
			
			def x
				@origin.x
			end
			
			def x_max
				if !@origin.x.nil? && !@size.width.nil?
					@origin.x + @size.width - 1
				end
			end
			
			def y
				@origin.y
			end
			
			def y_max
				if !@origin.y.nil? && !@size.height.nil?
					@origin.y + @size.height - 1
				end
			end
			
			def width
				@size.width
			end
			
			def height
				@size.height
			end
			
			def has_default_values?
				@origin.x.nil? && @origin.y.nil? && @size.width.nil? && @size.height.nil?
			end
			
			def to_s
				x_s = x.nil? ? 'NIL' : x
				y_s = y.nil? ? 'NIL' : y
				w_s = width.nil? ? 'NIL' : width
				h_s = height.nil? ? 'NIL' : height
				"#<#{self.class} #{x_s}:#{y_s} #{w_s}:#{h_s}>"
			end
			
		end
		
	end
end
