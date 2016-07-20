
module TheFox
	module TermKit
		
		class View
			
			def initialize
				#puts 'View initialize'
				
				@points = {}
				@subviews = []
			end
			
			def add_subview(subview)
				if !subview.is_a?(View)
					raise "subview is of wrong class: #{subview.class}"
				end
				
				@subviews.push(subview)
			end
			
			def remove_subview(subview)
				@subviews.delete(subview)
			end
			
			def subviews
				@subviews
			end
			
			def render(max_x = nil, max_y = nil)
				rows = {}
				@points.sort.each do |y_pos, row|
					x_pos_prev = 0
					current_block = nil
					row.sort.each do |x_pos, x_char|
						#puts "#{x_pos_prev}   #{x_pos} => #{x_char}"
						
						if x_pos == x_pos_prev + 1
							#puts "   prev ok"
							current_block.append(x_char.clone)
						else
							#puts "   new"
							if !rows[y_pos]
								rows[y_pos] = []
							end
							
							current_block = ViewContent.new(x_pos, x_char.clone)
							rows[y_pos] << current_block
						end
						
						if !max_x.nil? && x_pos >= max_x
							break
						end
						
						x_pos_prev = x_pos
					end
					
					if !max_y.nil? && y_pos >= max_y
						break
					end
				end
				#pp rows
				rows.sort.to_h
			end
			
			def set_point(point, content)
				if !point.is_a?(Point)
					raise "point is of wrong class: #{point.class}"
				end
				
				if @points[point.y].nil?
					@points[point.y] = {}
				end
				
				@points[point.y][point.x] = content.clone
			end
			
		end
		
	end
end
