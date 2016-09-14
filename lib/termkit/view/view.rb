
require 'thefox-ext'

module TheFox
	module TermKit
		
		##
		# Base View class
		class View
			
			##
			# The +name+ variable is only for debugging.
			attr_accessor :name
			attr_accessor :parent_view
			attr_accessor :subviews
			attr_accessor :grid
			attr_accessor :grid_cache
			attr_reader :position
			attr_accessor :zindex
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
				@parent_view = nil
				@subviews = []
				@grid = {}
				@grid_cache = {}
				
				@is_visible = false
				@position = Point.new(0, 0)
				@zindex = nil
			end
			
			def is_visible=(is_visible)
				trend = 0
				
				if @is_visible && !is_visible
					trend = -1
				elsif !@is_visible && is_visible
					trend = 1
				end
				
				@is_visible = is_visible
				
				redraw_parent(trend)
			end
			
			def is_visible?
				@is_visible
			end
			
			def position=(position)
				if !position.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{position.class} given"
				end
				
				@position = position
			end
			
			def add_subview(view)
				if view == self
					raise ArgumentError, 'self given'
				end
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				view.parent_view = self
				@subviews.push(view)
			end
			
			def remove_subview(view)
				if view == self
					raise ArgumentError, 'self given'
				end
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				@subviews.delete(view)
			end
			
			def draw_point(point, content)
				case point
				when Array, Hash
					point = Point.new(point)
				when Point
				else
					raise NotImplementedError, "#{content.class} class not implemented"
				end
				
				case content
				when String
					content = ViewContent.new(content, self)
				when ViewContent
				else
					raise NotImplementedError, "#{content.class} class not implemented"
				end
				
				is_foreign_point = content.view != self
				
				x_pos = point.x
				y_pos = point.y
				
				
				puts
				puts "#{@name} -- draw"
				
				
				if is_foreign_point
					x_pos += content.view.position.x
					y_pos += content.view.position.y
				else
					if !@grid[y_pos]
						@grid[y_pos] = {}
					end
					
					@grid[y_pos][x_pos] = content
				end
				
				puts "#{@name} -- draw #{x_pos}:#{y_pos} foreign=#{is_foreign_point ? 'Y' : 'N'} from=#{content.view.name}"
				
				
				if !@grid_cache[y_pos]
					@grid_cache[y_pos] = {}
				end
				
				puts "#{@name} -- subviews: #{@subviews.count}"
				
				changed = false
				
				if @subviews.count == 0
					@grid_cache[y_pos][x_pos] = content
					changed = true
				else
					puts "#{@name} -- has subviews"
					
					if @grid_cache[y_pos][x_pos]
						puts "#{@name} -- search subviews"
						
						redraw_zindex(Point.new(x_pos, y_pos))
					else
						puts "#{@name} -- draw free point"
						@grid_cache[y_pos][x_pos] = content
						changed = true
					end
				end
				
				if changed && is_visible? && !@parent_view.nil?
					puts "#{@name} -- draw parent: #{@parent_view.name}"
					@parent_view.draw_point(point, content)
				end
				
				return true
			end
			
			def redraw_parent(visibility_trend)
				puts "#{@name} -- redraw parent, #{visibility_trend}"
				
				if !@parent_view.nil?
					if visibility_trend == 1
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								puts "#{@name} -- redraw parent,  1, #{x_pos}:#{y_pos}"
								
								point = Point.new(x_pos, y_pos)
								@parent_view.draw_point(point, content)
							end
						end
					elsif visibility_trend == -1
						#@parent_view.redraw_zindex()
						
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								
								
								parent_x_pos = x_pos + @position.x
								parent_y_pos = y_pos + @position.y
								
								puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}"
								
								point = Point.new(parent_x_pos, parent_y_pos)
								
								if @parent_view.grid_cache[parent_y_pos] && 
									@parent_view.grid_cache[parent_y_pos][parent_x_pos] &&
									@parent_view.grid_cache[parent_y_pos][parent_x_pos] == content
									
									puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}, erase"
									@parent_view.grid_cache_erase_point(point)
								else
									puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}, not the same"
									
									
								end
							end
						end
					else
					end
				end
				
			end
			
			def grid_cache_erase_point(point)
				puts "#{@name} -- erase point, #{point}"
				
				x_pos = point.x
				y_pos = point.y
				
				if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
					#@grid_cache[y_pos][x_pos] = nil
					@grid_cache[y_pos].delete(x_pos)
					
					redraw_zindex(point)
				end
			end
			
			def redraw_zindex(point)
				puts "#{@name} -- redraw zindex, #{point}"
				
				pp @subviews.map{ |subview| subview.zindex }
			end
			
			def render
				
			end
			
		end
		
	end
end
