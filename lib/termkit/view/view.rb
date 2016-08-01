
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
				#puts "width #{width}"
				# puts "height #{height}"
				Size.new(width, height)
			end
			
			def grid
				@grid
			end
			
			def grid_recursive(area = nil, level = 0)
				tmp_grid = {}
				
				if area.nil?
					#puts '' + ("\t" * level) + 'create temp grid'
					
					@grid.each do |y_pos, row|
						tmp_grid[y_pos] = {}
						row.each do |x_pos, content|
							#puts '' + ("\t" * level) + "-> tg A #{x_pos}:#{y_pos} = '#{content}'"
							tmp_grid[y_pos][x_pos] = content.clone
						end
					end
					
					#puts '' + ("\t" * level) + 'temp grid A'
					#pp tmp_grid
					
					@subviews.each do |subview|
						sub_grid = subview.grid_recursive(nil, level + 1)
						sub_grid.each do |y_pos, row|
							y_pos_abs = y_pos + subview.position.y
							
							if !tmp_grid[y_pos_abs]
								tmp_grid[y_pos_abs] = {}
							end
							
							row.each do |x_pos, content|
								x_pos_abs = x_pos + subview.position.x
								
								#puts '' + ("\t" * level) + "-> sv A #{x_pos_abs}:#{y_pos_abs} (#{x_pos}:#{y_pos}) = '#{content}'"
								
								tmp_grid[y_pos_abs][x_pos_abs] = content
							end
						end
					end
					
					#puts '' + ("\t" * level) + 'temp grid B'
					#pp tmp_grid
				else
					if area.has_default_values?
						tmp_grid = grid_recursive(nil, level + 1)
					else
						
						#puts '' + ("\t" * level) + "area #{area}"
						
						y_range = area.origin.y..area.y_max
						x_range = area.origin.x..area.x_max
						
						y_range.each do |y_pos|
							row = @grid[y_pos]
							
							#puts '' + ("\t" * level) + "y #{y_pos}"
							
							if row
								x_range.each do |x_pos|
									content = row[x_pos]
									
									if content
										#puts '' + ("\t" * level) + "-> tg B #{x_pos}:#{y_pos} = '#{content}'"
										
										if !tmp_grid[y_pos]
											tmp_grid[y_pos] = {}
										end
										
										tmp_grid[y_pos][x_pos] = content.clone
									end
								end
							end
						end
						
						#puts '' + ("\t" * level) + "temp grid C: #{tmp_grid}"
						
						@subviews.each do |subview|
							sub_rect_x = area.x - subview.position.x
							sub_rect_width = area.size.width
							if sub_rect_x < 0
								sub_rect_x = 0
							end
							
							sub_rect_y = area.y - subview.position.y
							sub_rect_height = area.size.height
							if sub_rect_y < 0
								sub_rect_y = 0
							end
							
							tmp_rect = Rect.new
							tmp_rect.origin = subview.position
							tmp_rect.size = subview.size
							
							sub_rect = area & tmp_rect
							
							if sub_rect
								#puts '' + ("\t" * level) + "sub rect A: #{sub_rect}"
								#puts '' + ("\t" * level) + "tmp rect A: #{tmp_rect}"
								sub_rect = sub_rect - tmp_rect
								#sub_rect.size = subview.size
								#puts '' + ("\t" * level) + "sub rect B offset X: #{area.x - subview.position.x}"
								#puts '' + ("\t" * level) + "sub rect B offset Y: #{area.y - subview.position.y}"
								sub_rect.size = Size.new(area.width + area.x - subview.position.x, area.height + area.y - subview.position.y)
								if sub_rect.size.width > area.width
									sub_rect.size.width = area.width
								end
								if sub_rect.size.height > area.height
									sub_rect.size.height = area.height
								end
								#puts '' + ("\t" * level) + "sub rect B: #{sub_rect}"
								#puts '' + ("\t" * level) + "tmp rect B: #{tmp_rect}"
							end
							
							if sub_rect
								sub_grid = subview.grid_recursive(sub_rect, level + 1)
								sub_grid.each do |y_pos, row|
									
									#y_pos_abs = y_pos
									y_pos_abs = y_pos + subview.position.y
									
									row.each do |x_pos, content|
										
										#x_pos_abs = x_pos
										x_pos_abs = x_pos + subview.position.x
										
										if !tmp_grid[y_pos_abs]
											tmp_grid[y_pos_abs] = {}
										end
										
										tmp_grid[y_pos_abs][x_pos_abs] = content.clone
										
										#puts '' + ("\t" * level) + "  -> sub_grid #{x_pos_abs}:#{y_pos_abs} #{content}"
									end
								end
							end
						end
						
						#puts '' + ("\t" * level) + "temp grid D: #{tmp_grid}"
						
						if level == 0
							#puts '' + ("\t" * level) + "offset: #{area.origin.x}:#{area.origin.y}"
							
							tmp_grid2 = {}
							tmp_grid.each do |y_pos, row|
								y_pos_abs = y_pos - area.origin.y
								
								row.each do |x_pos, content|
									x_pos_abs = x_pos - area.origin.x
									
									#puts '' + ("\t" * level) + "  -> grid2 #{x_pos_abs}:#{y_pos_abs} #{content}"
									
									if !tmp_grid2[y_pos_abs]
										tmp_grid2[y_pos_abs] = {}
									end
									
									tmp_grid2[y_pos_abs][x_pos_abs] = content
								end
							end
							
							tmp_grid = tmp_grid2
						end
					end
				end
				
				#puts '' + ("\t" * level) + "temp grid END: #{tmp_grid}"
				
				tmp_grid
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
