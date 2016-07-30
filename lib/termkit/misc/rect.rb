
module TheFox
	module TermKit
		
		class Rect
			
			def initialize(x = nil, y = nil, width = nil, height = nil)
				@origin = Point.new(x, y)
				@size = Size.new(width, height)
			end
			
			def origin=(origin)
				@origin = origin
			end
			
			def origin
				@origin
			end
			
			def size=(size)
				@size = size
			end
			
			def size
				@size
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
			
			def is_subrect?(rect)
				if !rect.is_a?(Rect)
					raise ArgumentError, "Argument is not a Rect -- #{rect.class} given"
				end
				
				#pp self - rect
				!(self & rect).nil?
			end
			
			def ==(rect)
				if !rect.is_a?(Rect)
					raise ArgumentError, "Argument is not a Rect -- #{rect.class} given"
				end
				
				rect.x == self.x && rect.y == self.y && rect.width == self.width && rect.height == self.height
			end
			
			def &(obj)
				case obj
				when Rect
					#puts "#{obj.class} #{self.class}"
					if obj == self
						#puts "add =="
						
						Rect.new(obj.x, obj.y, obj.width, obj.height)
					else
						#puts "test #{obj.x} #{self.x} && #{obj.y} #{self.y} && #{obj.x_max} #{self.x_max} && #{obj.y_max} #{self.y_max}"
						
						xIsEqOrGt = obj.x >= self.x
						xIsLt = obj.x < self.x
						
						if obj.x_max.nil?
							xMaxIsGt = true
							xMaxIsLt = false
							
							xMaxIsEqOrLt = self.x_max.nil?
							
							if self.x_max.nil?
								xToXmaxIsEqOrLt = true
							else
								xToXmaxIsEqOrLt = obj.x <= self.x_max
							end
							
							xMaxToXIsEqOrGt = true
						else
							if self.x_max.nil?
								xMaxIsGt = false
								xMaxIsLt = true
								
								xMaxIsEqOrLt = true
								xToXmaxIsEqOrLt = true
							else
								xMaxIsGt = obj.x_max > self.x_max
								xMaxIsLt = obj.x_max < self.x_max
								
								xMaxIsEqOrLt = obj.x_max <= self.x_max
								xToXmaxIsEqOrLt = obj.x <= self.x_max
							end
							
							xMaxToXIsEqOrGt = obj.x_max >= self.x
						end
						
						
						yIsEqOrGt = obj.y >= self.y
						yIsLt = obj.y < self.y
						#puts "yIsLt #{yIsLt}"
						
						if obj.y_max.nil?
							
							yMaxIsGt = true
							yMaxIsLt = false
							
							yMaxIsEqOrLt = self.y_max.nil?
							
							if self.y_max.nil?
								yToYmaxIsEqOrLt = true
							else
								yToYmaxIsEqOrLt = obj.y <= self.y_max
							end
							
							yMaxToYIsEqOrGt = true
						else
							#puts "obj y max is NOT nil"
							
							if self.y_max.nil?
								yMaxIsGt = false
								yMaxIsLt = true
								
								yMaxIsEqOrLt = true
								yToYmaxIsEqOrLt = true
							else
								#puts "self y max is NOT nil"
								
								yMaxIsGt = obj.y_max > self.y_max
								yMaxIsLt = obj.y_max < self.y_max
								
								yMaxIsEqOrLt = obj.y_max <= self.y_max
								#puts "yMaxIsEqOrLt #{yMaxIsEqOrLt}"
								
								yToYmaxIsEqOrLt = obj.y <= self.y_max
								#puts "yToYmaxIsEqOrLt #{yToYmaxIsEqOrLt}"
							end
							
							yMaxToYIsEqOrGt = obj.y_max >= self.y
						end
						
						
						xBeginIsInner = xIsEqOrGt && xToXmaxIsEqOrLt
						yBeginIsInner = yIsEqOrGt && yToYmaxIsEqOrLt
						#puts "yBeginIsInner #{yBeginIsInner}"
						
						xEndIsInner = xMaxToXIsEqOrGt && xMaxIsEqOrLt
						yEndIsInner = yMaxToYIsEqOrGt && yMaxIsEqOrLt
						#puts "yEndIsInner #{yEndIsInner}"
						
						# puts "xIsLt #{xIsLt}"
						# puts "xMaxIsGt #{xMaxIsGt}"
						
						xIsOversize = xIsLt && xMaxIsGt
						yIsOversize = yIsLt && yMaxIsGt
						
						#puts "xIsOversize #{xIsOversize}"
						#puts "yIsOversize #{yIsOversize}"
						#puts
						
						x = nil
						width = nil
						if xBeginIsInner
							x = obj.x
							width = nil
							if xMaxIsLt
								#puts "& sub X A: xMaxIsLt #{width}"
								#width -= self.x_max - obj.x_max
								width = obj.width
							else
								width = self.width - (obj.x - self.y)
							end
							#puts "& sub X A: '#{x}' '#{width}'"
						elsif xEndIsInner
							x = self.x
							width = obj.x_max - self.x + 1
							#puts "& sub X B: '#{x}' '#{width}' (#{obj.x_max} - #{self.x} + 1)"
						elsif xIsOversize
							x = self.x
							width = self.width
							#puts "& sub X C: '#{x}' '#{width}'"
						end
						
						y = nil
						height = nil
						if yBeginIsInner
							y = obj.y
							height = nil
							if yMaxIsLt
								puts "& sub Y A: yMaxIsLt"
								height = obj.height
							else
								puts "height = #{self.height} - (#{obj.y} - #{self.y})"
								height = self.height - (obj.y - self.y)
							end
							puts "& sub Y A: '#{y}' '#{height}'"
						elsif yEndIsInner
							y = self.y
							height = obj.y_max - self.y + 1
							puts "& sub Y B: '#{y}' '#{height}'"
						elsif yIsOversize
							y = self.y
							height = self.height
							puts "& sub Y C: '#{y}' '#{height}'"
						end
						
						puts "& new rect: '#{x}' '#{y}' '#{width}' '#{height}'"
						if !x.nil? && !y.nil? && !width.nil? && !height.nil?
							Rect.new(x, y, width, height)
						end
					end
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def -(obj)
				case obj
				when Rect
					
					x = nil
					y = nil
					width = nil
					height = nil
					
					x = self.x - obj.x
					y = self.y - obj.y
					width = self.width
					height = self.height
					
					puts "x #{self.x} #{obj.x} #{x}"
					puts "y #{self.y} #{obj.y} #{y}"
					puts "width #{self.width} #{obj.width} #{width}"
					puts "height #{self.height} #{obj.height} #{height}"
					
					puts "- new rect: '#{x}' '#{y}' '#{width}' '#{height}'"
					if !x.nil? && !y.nil? # && !width.nil? && !height.nil?
						Rect.new(x, y, width, height)
					end
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def to_s
				"#<#{self.class} #{x}:#{y} #{width}:#{height}>"
			end
		end
		
	end
end
