
module TheFox
	module TermKit
		
		class Rect
			
			def initialize(x = nil, y = nil, width = nil, height = nil)
				@origin = Point.new(x, y)
				@size = Size.new(width, height)
			end
			
			def origin
				@origin
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
				
				pp self - rect
				!(self - rect).nil?
			end
			
			def ==(rect)
				if !rect.is_a?(Rect)
					raise ArgumentError, "Argument is not a Rect -- #{rect.class} given"
				end
				
				rect.x == self.x && rect.y == self.y && rect.width == self.width && rect.height == self.height
			end
			
			def ===(rect)
				if !rect.is_a?(Rect)
					raise ArgumentError, "Argument is not a Rect -- #{rect.class} given"
				end
				
				raise NotImplementedError
			end
			
			def >(obj)
				case obj
				when Rect
					self.width > obj.width && self.height > obj.height
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def >=(obj)
				case obj
				when Rect
					self > obj || self == obj
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def <(obj)
				case obj
				when Rect
					self.width < obj.width && self.height < obj.height
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def <=(obj)
				case obj
				when Rect
					self < obj || self == obj
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
			
			def -(obj)
				case obj
				when Rect
					#puts "#{obj.class} #{self.class}"
					if obj == self
						puts "sub =="
						
						Rect.new(obj.x, obj.y, obj.width, obj.height)
					else
						#puts "test #{obj.x} #{self.x} && #{obj.y} #{self.y} && #{obj.x_max} #{self.x_max} && #{obj.y_max} #{self.y_max}"
						
						xIsEqOrGt = obj.x >= self.x
						xIsLt = obj.x < self.x
						yIsEqOrGt = obj.y >= self.y
						yIsLt = obj.y < self.y
						
						xMaxIsGt = obj.x_max > self.x_max
						xMaxIsLt = obj.x_max < self.x_max
						xMaxIsEqOrLt = obj.x_max <= self.x_max
						yMaxIsGt = obj.y_max > self.y_max
						yMaxIsLt = obj.y_max < self.y_max
						yMaxIsEqOrLt = obj.y_max <= self.y_max
						
						xToXmaxIsEqOrLt = obj.x <= self.x_max
						yToYmaxIsEqOrLt = obj.y <= self.y_max
						
						xmaxToXIsEqOrGt = obj.x_max >= self.x
						ymaxToYIsEqOrGt = obj.y_max >= self.y
						
						xBeginIsInner = xIsEqOrGt && xToXmaxIsEqOrLt
						yBeginIsInner = yIsEqOrGt && yToYmaxIsEqOrLt
						
						xEndIsInner = xmaxToXIsEqOrGt && xMaxIsEqOrLt
						yEndIsInner = ymaxToYIsEqOrGt && yMaxIsEqOrLt
						
						beginIsInner = xBeginIsInner && yBeginIsInner
						endIsInner = xEndIsInner && yEndIsInner
						
						xIsOversize = xIsLt && xMaxIsGt
						yIsOversize = yIsLt && yMaxIsGt
						
						isOversize = xIsOversize && yIsOversize
						
						x = nil
						width = nil
						xHasVal = true
						if xBeginIsInner
							x = obj.x
							width = self.x_max - obj.x + 1
							if xMaxIsLt
								width -= self.x_max - obj.x_max
							end
							puts "sub X A: #{width}"
						elsif xEndIsInner
							x = self.x
							width = obj.x_max - self.x + 1
							puts "sub X B: #{width}"
						elsif xIsOversize
							x = self.x
							width = self.width
						else
							xHasVal = false
						end
						
						y = nil
						height = nil
						yHasVal = true
						if yBeginIsInner
							y = obj.y
							height = self.y_max - obj.y + 1
							if yMaxIsLt
								height -= self.y_max - obj.y_max
							end
							puts "sub Y A: #{height}"
						elsif yEndIsInner
							y = self.y
							height = obj.y_max - self.y + 1
							puts "sub Y B: #{height}"
						elsif yIsOversize
							y = self.y
							height = self.height
						else
							yHasVal = false
						end
						
						puts "has val: #{xHasVal} #{yHasVal}"
						if !x.nil? && !y.nil? && !width.nil? && !height.nil?
							Rect.new(x, y, width, height)
						end
					end
				else
					raise NotImplementedError, "Class '#{obj.class}' not implemented yet"
				end
			end
		end
		
	end
end
