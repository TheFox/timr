
require 'thefox-ext'

module TheFox
	module TermKit
		
		class View
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name
				@is_visible = false
				@position = Point.new(0, 0)
				@size = nil
				@grid = {}
				@subviews = []
			end
			
			def is_visible=(is_visible)
				@is_visible = is_visible
			end
			
			def is_visible?
				@is_visible
			end
			
			def position
				@position
			end
			
			def size
				width = @grid.map{ |y, row| row.keys.max }.max + 1
				height = @grid.keys.max + 1
				puts "width #{width}"
				# puts "height #{height}"
				Size.new(width, height)
			end
			
			def grid
				@grid
			end
			
			def grid_recursive(area = nil, level = 0)
				tmp_grid = {}
				
				if area.nil?
					@grid.each do |y_pos, row|
						tmp_grid[y_pos] = {}
						row.each do |x_pos, content|
							#puts '' + ('  ' * level) + "-> tg A #{x_pos}:#{y_pos} = '#{content}'"
							tmp_grid[y_pos][x_pos] = content.clone
						end
					end
					
					@subviews.each do |subview|
						sub_grid = subview.grid_recursive(nil, level + 1)
						sub_grid.each do |y_pos, row|
							y_pos_abs = y_pos + subview.position.y
							
							if !tmp_grid[y_pos_abs]
								tmp_grid[y_pos_abs] = {}
							end
							
							row.each do |x_pos, content|
								x_pos_abs = x_pos + subview.position.x
								
								#puts '' + ('  ' * level) + "-> sv A #{x_pos_abs}:#{y_pos_abs} (#{x_pos}:#{y_pos}) = '#{content}'"
								
								tmp_grid[y_pos_abs][x_pos_abs] = content
							end
						end
					end
				else
					if area.has_default_values?
						tmp_grid = grid_recursive(nil, level + 1)
					else
						
						y_range = area.origin.y..area.y_max
						x_range = area.origin.x..area.x_max
						
						tmp_grid_row = nil
						y_range.each do |y_pos|
							row = @grid[y_pos]
							
							#puts '' + ('  ' * level) + "y #{y_pos}"
							
							if row
								x_range.each do |x_pos|
									content = row[x_pos]
									
									if content
										#puts '' + ('  ' * level) + "-> tg B #{x_pos}:#{y_pos} = '#{content}'"
										
										if !tmp_grid[y_pos]
											tmp_grid[y_pos] = tmp_grid_row = {}
										end
										
										tmp_grid_row[x_pos] = content.clone
									end
								end
							end
						end
						
						#puts '' + ('  ' * level) + "area #{area.x}:#{area.y} #{area.width}:#{area.height}"
						puts '' + ('  ' * level) + "area #{area}"
						
						@subviews.each do |subview|
							puts '' + ('  ' * level) + "subview  #{subview.position.x}:#{subview.position.y}"
							
							
							
							sub_rect_x = area.x - subview.position.x
							sub_rect_width = area.size.width
							if sub_rect_x < 0
								#sub_rect_width += sub_rect_x
								sub_rect_x = 0
							end
							
							sub_rect_y = area.y - subview.position.y
							sub_rect_height = area.size.height
							if sub_rect_y < 0
								#sub_rect_width += sub_rect_y
								sub_rect_y = 0
							end
							
							sub_rect = nil
							#sub_rect = Rect.new(sub_rect_x, sub_rect_y, sub_rect_width, sub_rect_height)
							puts '' + ('  ' * level) + "sub_rect #{sub_rect_x}:#{sub_rect_y} #{sub_rect_width}:#{sub_rect_height}"
							
							tmp_rect = Rect.new
							tmp_rect.origin = subview.position
							tmp_rect.size = subview.size
							puts '' + ('  ' * level) + "tmp_rect '#{tmp_rect}'"
							
							sub_rect = area & tmp_rect
							#sub_rect = tmp_rect & area
							puts '' + ('  ' * level) + "sub_rect A '#{sub_rect}'"
							
							#sub_rect = nil
							
							if sub_rect
								sub_rect = sub_rect - tmp_rect
								puts '' + ('  ' * level) + "sub_rect B '#{sub_rect}'"
							end
							
							if sub_rect
								puts '' + ('  ' * level) + "sub_rect ok"
								
								tmp_grid_row = nil
								sub_grid = subview.grid_recursive(sub_rect, level + 1)
								sub_grid.each do |y_pos, row|
									
									#y_pos_abs = y_pos
									y_pos_abs = y_pos + subview.position.y
									#y_pos_abs = y_pos + subview.position.y - area.origin.y
									
									puts '' + ('  ' * level) + "-> sg y #{y_pos} -> #{y_pos_abs}"
									
									row.each do |x_pos, content|
										
										#x_pos_abs = x_pos
										x_pos_abs = x_pos + subview.position.x
										#x_pos_abs = x_pos + subview.position.x - area.origin.x
										
										puts '' + ('  ' * level) + "-> sg x #{x_pos} -> #{x_pos_abs} #{content}"
										
										if !tmp_grid[y_pos_abs]
											tmp_grid[y_pos_abs] = tmp_grid_row = {}
										end
										
										tmp_grid_row[x_pos_abs] = content.clone
										
									end
								end
							end
							
						end
						
						#pp tmp_grid
						
						tmp_grid2_x_offset = tmp_grid.map{ |y, row| row.keys.min }.min
						tmp_grid2_y_offset = tmp_grid.keys.min
						
						#puts "tmp_grid2_x_offset #{tmp_grid2_x_offset}"
						
						#puts "tmp_grid2_y_offset #{tmp_grid2_y_offset}"
						
						tmp_grid2 = {}
						tmp_grid.sort.each do |y_pos, row|
							if tmp_grid2_y_offset.nil?
								tmp_grid2_y_offset = y_pos
							end
							
							y_pos_abs = y_pos - tmp_grid2_y_offset
							
							row.sort.each do |x_pos, content|
								if tmp_grid2_x_offset.nil?
									tmp_grid2_x_offset = x_pos
								end
								
								x_pos_abs = x_pos - tmp_grid2_x_offset
								
								
								#puts '' + ('  ' * level) + "grid2 #{x_pos_abs}:#{y_pos_abs} #{content}"
								
								if !tmp_grid2[y_pos_abs]
									tmp_grid2[y_pos_abs] = {}
								end
								
								tmp_grid2[y_pos_abs][x_pos_abs] = content
							end
						end
						
						tmp_grid = tmp_grid2
						pp tmp_grid2
						
					end
				end
				
				#pp tmp_grid # if level == 0
				
				tmp_grid
				
				
				
				
				
			end
			
			def grid_recursive1(area = nil, level = 0)
				x_min = nil.freeze
				x_max = nil.freeze
				y_min = nil.freeze
				y_max = nil.freeze
				width = nil.freeze
				height = nil.freeze
				
				if !area.nil? && area.has_default_values?
					area = nil
				end
				if !area.nil?
					x_min = area.origin.x.freeze
					x_max = area.x_max.freeze
					y_min = area.origin.y.freeze
					y_max = area.y_max.freeze
					
					width = area.size.width
					height = area.size.height
				end
				
				puts "view:  #{@name}[#{level}]"
				puts "  x: #{x_min.nil? ? 'nil' : x_min} -> #{x_max.nil? ? 'nil' : x_max}"
				puts "  y: #{y_min.nil? ? 'nil' : y_min} -> #{y_max.nil? ? 'nil' : y_max}"
				#puts "  width: #{width.nil? ? 'nil' : width}   height: #{height.nil? ? 'nil' : height}"
				
				tmp_grid = {}
				@grid.each do |y_pos, row|
					y_pos_abs = y_pos.freeze
					if !y_min.nil?
						if y_pos < y_min
							#puts "  skip y #{y_pos} #{y_min}"
							next
						end
						
						y_pos_abs = (y_pos - y_min).freeze
						# puts "  take y #{y_pos_abs}"
					else
						# puts "  take nil y #{y_pos_abs}"
					end
					
					tmp_grid[y_pos_abs] = {}
					
					row.sort.each do |x_pos, content|
						x_pos_abs = x_pos.freeze
						if !x_min.nil?
							if x_pos < x_min
								# puts "  skip x #{x_pos} #{x_min}"
								next
							end
							
							x_pos_abs = (x_pos - x_min).freeze
							# puts "  take x #{x_pos_abs}"
						else
							# puts "  take nil x #{x_pos_abs}"
						end
						
						puts "  -> tg #{x_pos_abs}:#{y_pos_abs} = '#{content}'"
						
						tmp_grid[y_pos_abs][x_pos_abs] = content.clone
						
						if !x_max.nil? && x_pos >= x_max
							break
						end
					end
					
					if !y_max.nil? && y_pos >= y_max
						break
					end
				end
				
				#pp tmp_grid
				
				@subviews.each do |subview|
					subview_position = subview.position
					subview_x_pos = subview_position.x
					subview_y_pos = subview_position.y
					
					
					
					puts "  subview #{subview_x_pos}:#{subview_y_pos}"
					
					sub_rect = nil
					sub_rect_x = nil
					sub_rect_y = nil
					sub_rect_width = nil
					sub_rect_height = nil
					sub_rect_x_reset = false
					sub_rect_y_reset = false
					
					if !area.nil?
						if subview_x_pos > x_max || subview_y_pos > y_max
							next
						end
						
						sub_rect_x = x_min - subview_x_pos
						sub_rect_y = y_min - subview_y_pos
						sub_rect_width = width
						sub_rect_height = height
						
						if sub_rect_x < 0
							puts "  reset x: #{sub_rect_x} #{sub_rect_width}"
							sub_rect_width += sub_rect_x
							#sub_rect_width = x_max - subview_x_pos
							sub_rect_x = 0
							sub_rect_x_reset = true
						end
						if sub_rect_y < 0
							puts "  reset y: #{sub_rect_y} #{sub_rect_height}"
							sub_rect_height += sub_rect_y
							#sub_rect_height = y_max - subview_y_pos
							sub_rect_y = 0
							sub_rect_y_reset = true
						end
						
						sub_rect = Rect.new(sub_rect_x, sub_rect_y, sub_rect_width, sub_rect_height)
					end
					
					puts "  sub_rect #{sub_rect_x}:#{sub_rect_y} #{sub_rect_width}:#{sub_rect_height}"
					
					
					sub_grid = subview.grid_recursive(sub_rect, level + 1)
					#pp sub_grid
					sub_grid.each do |y_pos, row|
						
						y_pos_abs = y_pos
						if sub_rect_y_reset
							y_pos_abs = y_pos + subview_y_pos
						end
						
						if !tmp_grid[y_pos_abs]
							tmp_grid[y_pos_abs] = {}
						end
						
						row.sort.each do |x_pos, content|
							
							x_pos_abs = x_pos
							if sub_rect_x_reset
								x_pos_abs = x_pos + subview_x_pos
							end
							
							puts "     -> #{x_pos_abs}:#{y_pos_abs} (#{x_pos}:#{y_pos}) = '#{content}'"
							
							tmp_grid[y_pos_abs][x_pos_abs] = content
							
							if !x_max.nil? && x_pos_abs >= x_max
								break
							end
						end
						
						if !y_max.nil? && y_pos_abs >= y_max
							break
						end
					end
				end
				#pp tmp_grid
				tmp_grid.sort.to_h
			end
			
			def position=(point)
				if !point.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{point.class} given"
				end
				
				@position = point
			end
			
			def add_subview(subview)
				if !subview.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{subview.class} given"
				end
				if !@subviews.is_a?(Array)
					raise Exception::ParentClassNotInitializedException, "@subviews is not an Array -- #{@subviews.class} given"
				end
				
				@subviews.push(subview)
			end
			
			def remove_subview(subview)
				@subviews.delete(subview)
			end
			
			def subviews
				@subviews
			end
			
			def render(area = nil)
				rows = {}
				if @is_visible
					grid_recursive(area).sort.each do |y_pos, row|
						x_pos_prev = 0
						current_block = nil
						current_row = nil
						row.sort.each do |x_pos, x_char|
							if !current_block.nil? && x_pos == x_pos_prev + 1
								current_block.append(x_char)
							else
								if !rows[y_pos]
									rows[y_pos] = current_row = []
								end
								
								current_block = ViewContent.new(x_pos, x_char)
								current_row << current_block
							end
							
							x_pos_prev = x_pos
						end
					end
				end
				#pp rows
				rows.sort.to_h
			end
			
			def draw_point(point, content)
				if !point.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{point.class} given"
				end
				
				if @grid[point.y].nil?
					@grid[point.y] = {}
				end
				
				@grid[point.y][point.x] = content[0]
			end
			
			def to_s
				to_s_rect
			end
			
			def to_s_rect(area = nil)
				s = ''
				y_pos_prev = 0
				render(area).each do |y_pos, row|
					y_diff = y_pos - y_pos_prev
					if y_diff > 0
						s << "\n" * y_diff
					end
					
					x_pos_prev = -1
					row.each do |vcontent|
						x_diff = vcontent.start_x - x_pos_prev - 1
						if x_diff > 0
							s << ' ' * x_diff
						end
						s << vcontent.content
						x_pos_prev = vcontent.start_x + vcontent.content.length - 1
					end
					
					y_pos_prev = y_pos
				end
				s
			end
			
		end
		
	end
end
