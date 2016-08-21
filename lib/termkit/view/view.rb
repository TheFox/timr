
require 'thefox-ext'

module TheFox
	module TermKit
		
		class View
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
				@is_visible = false
				@visibility_trend = 0
				@position = Point.new(0, 0)
				@offset = nil
				@size = nil
				@grid = {}
				grid_clear
				
				@needs_rendering = true
				@parent_view = nil
				@subviews = []
			end
			
			def name=(name)
				@name = name
			end
			
			def name
				@name
			end
			
			def is_visible=(is_visible)
				#puts "view '#{@name}' v=#{is_visible ? 'Y' : '-'}"
				@visibility_trend = 0
				if !@is_visible && is_visible
					@visibility_trend = 1
				elsif @is_visible && !is_visible
					@visibility_trend = -1
				end
				
				@is_visible = is_visible
				self.needs_rendering = true
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
			
			def offset=(offset)
				@offset = offset
			end
			
			def offset
				@offset
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
			
			def draw_point(point, content)
				if !point.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{point.class} given"
				end
				
				if @grid[point.y].nil?
					@grid[point.y] = {}
				end
				
				view_content = nil
				case content
				when String
					view_content = ViewContent.new(self, content)
				when ViewContent
					view_content = content
				else
					raise NotImplementedError, "Class '#{content.class}' not implemented yet"
				end
				
				@grid[point.y][point.x] = view_content
				self.needs_rendering = true
			end
			
			def grid
				@grid
			end
			
			def grid_clear(recursive = false)
				@grid = {}
				
				if recursive
					@subviews.each do |subview|
						subview.grid_clear(recursive)
					end
				end
				
				self.needs_rendering = true
			end
			
			def render(area = nil, level = 0)
				if !@is_visible && @visibility_trend == 0
					return {}
				end
				
				tmp_grid = {}
				
				if area.nil?
					if !@offset.nil? || !@size.nil?
						area = Rect.new(0, 0)
						if !@offset.nil?
							area.origin = @offset
						end
						if !@size.nil?
							area.size = @size
						end
					end
				else
					if !@offset.nil?
						area.origin = @offset
					end
				end
				
				if area.nil?
					
					hide_view = @visibility_trend == -1
					
					render_grid = @visibility_trend != 0
					
					
					puts "view '#{self.name}' a=#{render_grid ? 'Y' : '-'} v=#{@is_visible ? 'Y' : '-'} r=#{@needs_rendering ? 'Y' : '-'} h=#{hide_view ? 'Y' : '-'}"
					
					
					
					@grid.each do |y_pos, row|
						tmp_grid[y_pos] = {}
						row.each do |x_pos, content|
							puts "view grid #{x_pos}:#{y_pos} c='#{content.char}'  cr=#{content.needs_rendering? ? 'Y' : '-'}"
							if render_grid || content.needs_rendering?
								content.hide = hide_view
								
								tmp_grid[y_pos][x_pos] = content
							end
						end
					end
					
					puts "subviews #{@subview.nil? ? 0 : @subview.count}"
					
					#@subviews.select{ |subview| subview.is_visible? }.each do |subview|
					@subviews.each do |subview|
						puts "subview '#{subview.name}' r=#{subview.needs_rendering? ? 'Y' : '-'}"
						
						x_offset = 0
						y_offset = 0
						if !subview.offset.nil?
							x_offset = subview.offset.x
							y_offset = subview.offset.y
						end
						
						sub_grid = subview.render(nil, level + 1)
						sub_grid.each do |y_pos, row|
							y_pos_abs = y_pos + subview.position.y - y_offset
							
							if !tmp_grid[y_pos_abs]
								tmp_grid[y_pos_abs] = {}
							end
							
							row.each do |x_pos, content|
								x_pos_abs = x_pos + subview.position.x - x_offset
								
								is_set = tmp_grid[y_pos_abs] && tmp_grid[y_pos_abs][x_pos_abs]
								nis_set = !tmp_grid[y_pos_abs] || !tmp_grid[y_pos_abs][x_pos_abs]
								
								puts "subview grid #{x_pos_abs}:#{y_pos_abs} c='#{content.char}' r=#{content.needs_rendering? ? 'Y' : '-'} s=#{is_set ? 'Y' : '-'}/#{nis_set ? 'Y' : '-'}"
								
								tmp_grid[y_pos_abs][x_pos_abs] = content
							end
						end
					end
				else
					if area.has_default_values?
						tmp_grid = render(nil, level + 1)
					else
						
						if @grid.keys.count > 0
							y_range_min = area.origin.y
							y_range_max = area.y_max
							if y_range_max.nil?
								y_range_max = @grid.keys.max
							end
							y_range = y_range_min..y_range_max
							
							x_range_min = area.origin.x
							x_range_max = area.x_max
							x_range_max_dyn = x_range_max.nil?
							
							y_range.each do |y_pos|
								row = @grid[y_pos]
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
									
									(x_range_min..x_range_max).each do |x_pos|
										content = row[x_pos]
										if content
											
											if !tmp_grid[y_pos]
												tmp_grid[y_pos] = {}
											end
											
											tmp_grid[y_pos][x_pos] = content.clone
										end
									end
								end
							end
						end
							
						@subviews.select{ |subview| subview.is_visible? }.each do |subview|
							subview_x_offset = 0
							subview_y_offset = 0
							if !subview.offset.nil?
								subview_x_offset = subview.offset.x
								subview_y_offset = subview.offset.y
							end
							
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
								
								sub_rect.size = Size.new(size_width, size_height)
							end
							
							if sub_rect
								sub_grid = subview.render(sub_rect, level + 1)
								sub_grid.each do |y_pos, row|
									y_pos_abs = y_pos + subview.position.y - subview_y_offset
									
									row.each do |x_pos, content|
										x_pos_abs = x_pos + subview.position.x - subview_x_offset
										
										if !tmp_grid[y_pos_abs]
											tmp_grid[y_pos_abs] = {}
										end
										
										tmp_grid[y_pos_abs][x_pos_abs] = content.clone
									end
								end
							end
						end
						
						if level == 0
							tmp_grid2 = {}
							tmp_grid.each do |y_pos, row|
								y_pos_abs = y_pos - area.origin.y
								
								row.each do |x_pos, content|
									x_pos_abs = x_pos - area.origin.x
									
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
				
				@visibility_trend = 0
				@needs_rendering = false
				
				tmp_grid
			end
			
			def needs_rendering=(needs_rendering = true)
				#puts "view '#{@name}' r=#{needs_rendering ? 'Y' : '-'}"
				
				@needs_rendering = needs_rendering
				
				if needs_rendering && !@parent_view.nil?
					@parent_view.needs_rendering = true
				end
			end
			
			def needs_rendering?
				@needs_rendering
			end
			
			def parent_view=(parent_view)
				@parent_view = parent_view
			end
			
			def add_subview(subview)
				if !subview.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{subview.class} given"
				end
				if !@subviews.is_a?(Array)
					raise Exception::ParentClassNotInitializedException, "@subviews is not an Array -- #{@subviews.class} given"
				end
				
				subview.parent_view = self
				@subviews.push(subview)
				self.needs_rendering = true
			end
			
			def remove_subview(subview)
				subview.parent_view = nil
				@subviews.delete(subview)
				self.needs_rendering = true
			end
			
			def subviews
				@subviews
			end
			
			def to_s
				to_s_rect
			end
			
			def to_s_rect(area = nil)
				rows = render(area)
				rows.sort.to_h.map{ |y_pos, row| row.sort.to_h.values.map{ |view_content| view_content.render }.join }.join("\n")
			end
			
		end
		
	end
end
