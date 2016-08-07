
require 'thefox-ext'

module TheFox
	module TermKit
		
		class View
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
				@is_visible = false
				@position = Point.new(0, 0)
				@size = nil
				@grid = {}
				grid_clear
				@subviews = []
			end
			
			def name
				@name
			end
			
			def is_visible=(is_visible)
				@is_visible = is_visible
			end
			
			def is_visible?
				@is_visible
			end
			
			def position=(point)
				if !point.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{point.class} given"
				end
				
				@position = point
			end
			
			def position
				@position
			end
			
			def size=(size)
				@size = size
			end
			
			def size
				@size
			end
			
			def bounds
				width = nil
				height = nil
				
				if @grid.keys.count > 0
					width = @grid.map{ |y, row|
						if row.keys.count > 0
							row.keys.max
						else
							0
						end
					}.max + 1
					height = @grid.keys.nil? ? nil : @grid.keys.max + 1
				end
				
				#puts "width #{width}"
				#puts "height #{height}"
				
				Size.new(width, height)
			end
			
			def height(level = 0)
				keys = @grid.keys
				if keys.nil?
					0
				else
					grid_min = 0
					grid_max = 0
					if keys.count > 0
						grid_min = keys.min
						grid_max = keys.max
					end
					
					#puts '' + ("\t" * level) + "keys: #{keys}"
					#puts '' + ("\t" * level) + "grid_min: #{grid_min}"
					#puts '' + ("\t" * level) + "grid_max: #{grid_max}"
					
					@subviews.each do |subview|
						subview_h = subview.height(level + 1)
						subview_y_pos = subview.position.y.nil? ? 0 : subview.position.y
						subview_h_abs_min = subview_y_pos
						subview_h_abs_max = subview_h + subview_y_pos
						
						#puts '' + ("\t" * level) + "subview: '#{subview.name}'   h=#{subview_h} y=#{subview.position.y} abs_min=#{subview_h_abs_min} abs_max=#{subview_h_abs_max} grid_min=#{grid_min} grid_max=#{grid_max}"
						
						if subview_h_abs_min < grid_min
							grid_min = subview_h_abs_min
							#puts '' + ("\t" * level) + "new grid_min: #{grid_min}"
						end
						if subview_h_abs_max > grid_max
							grid_max = subview_h_abs_max - 1
							#puts '' + ("\t" * level) + "new grid_max: #{grid_max}"
						end
					end
					
					grid_max - grid_min + 1
				end
			end
			
			def grid
				@grid
			end
			
			def grid_clear
				@grid = {}
			end
			
			def grid_clear_recursive
				@subviews.each do |subview|
					subview.grid_clear
				end
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
						
						#y_range = area.origin.y..area.y_max
						#x_range = area.origin.x..area.x_max
						
						#puts "x_range '#{x_range}'"
						
						if @grid.keys.count > 0
							y_range_min = area.origin.y
							y_range_max = area.y_max
							if y_range_max.nil?
								#puts "y_range_max is nil"
								y_range_max = @grid.keys.max
							end
							y_range = y_range_min..y_range_max
							
							x_range_min = area.origin.x
							x_range_max = area.x_max
							x_range_max_dyn = x_range_max.nil?
							
							#puts "start x_range_max: #{x_range_max}"
							
							y_range.each do |y_pos|
								row = @grid[y_pos]
								
								#puts '' + ("\t" * level) + "y #{y_pos}"
								
								if row && row.keys.count > 0
									if x_range_max_dyn
										row_max = row.keys.max
										if x_range_max.nil?
											x_range_max = row_max
										else
											if row_max > x_range_max
												x_range_max = row_max
											end
										end
									end
									
									#puts "real x range     : #{x_range_min} #{x_range_max}"
									
									(x_range_min..x_range_max).each do |x_pos|
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
							tmp_rect.size = subview.bounds
							
							sub_rect = area & tmp_rect
							
							if sub_rect
								sub_rect = sub_rect - tmp_rect
								
								#puts "sub_rect w: '#{area.width}' N=#{area.width.nil?}"
								#puts "sub_rect x: '#{area.x}' N=#{area.x.nil?}"
								
								size_width = nil
								if !area.width.nil?
									size_width = area.width + area.x - subview.position.x
									if size_width > area.width
										size_width = area.width
									end
								end
								
								size_height = nil
								if !area.height.nil?
									size_height = area.height + area.y - subview.position.y
									if size_height > area.height
										size_height = area.height
									end
								end
								
								#puts "size_width : '#{size_width}' N=#{size_width.nil?}"
								#puts "size_height: '#{size_height}' N=#{size_height.nil?}"
								#puts
								
								sub_rect.size = Size.new(size_width, size_height)
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
					
					if area.nil? && !@size.nil?
						#puts "size: #{@size}"
						
						area = Rect.new(0, 0)
						area.size = @size
					end
					
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
