
module TheFox
	module TermKit
		
		class TableView < View
			
			def initialize(name = nil)
				super(name)
				
				#puts 'TableView->initialize'
				
				@header_cell_view = nil
				@header_height = 0
				@table_data = []
				@cells = []
				
				@page = []
				@page_begin = 1
				@page_height = 0
				@page_height_total = 0
				@page_needs_refresh = true
				
				@cursor_position = 1
				@cursor_position_old = 1
				@cursor_direction = 0
				
				@table = View.new('table')
				@table.is_visible = true
				add_subview(@table)
			end
			
			def size=(size)
				super(size)
				
				#puts "set size: #{@size}"
				
				if !@size.height.nil?
					@page_height = @size.height - @header_height
				end
			end
			
			def header_cell_view=(header_cell_view)
				if !header_cell_view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{header_cell_view.class} given"
				end
				
				if !@header_cell_view.nil?
					remove_subview(@header_cell_view)
				end
				@header_cell_view = header_cell_view
				add_subview(@header_cell_view)
				@header_height = @header_cell_view.height
				
				if !@size.nil?
					@page_height = @size.height - @header_height
				end
			end
			
			def table_data=(table_data)
				if !table_data.is_a?(Array)
					raise ArgumentError, "Argument is not a Array -- #{table_data.class} given"
				end
				
				@table_data = table_data
				@cells = []
				@page_needs_refresh = true
				
				cell_n = 0
				y_pos = 0
				@table_data.each do |row|
					cell = nil
					cell_n += 1
					
					case row
					when String
						text_view = TextView.new()
						text_view.is_visible = true
						text_view.text = row
						
						cell = CellTableView.new(text_view)
						cell.name = "cell_#{cell_n}"
					when CellTableView
						cell = row
					else
						raise NotImplementedError, "Class '#{row.class}' not implemented yet"
					end
					
					@cells.push(cell)
					
					cell.is_visible = true
					cell.position = Point.new(0, y_pos)
					@table.add_subview(cell)
					
					y_pos += cell.height
				end
				
				@page_height_total = y_pos
			end
			
			def render(area = nil)
				render_cells
				
				# if area.nil?
				# 	area = Rect.new(0, 0)
				# end
				
				super(area)
			end
			
			def cursor_position=(cursor_position)
				@cursor_position_old = @cursor_position
				@cursor_position = cursor_position
				
				# -1 up
				#  0 unchanged
				# +1 down
				cds = '='
				if @cursor_position == @cursor_position_old
					@cursor_direction = 0
				elsif @cursor_position > @cursor_position_old
					@cursor_direction = 1
					cds = 'v'
				else
					@cursor_direction = -1
					cds = '^'
				end
				
				cursor_position_max = 100
				
				if @cursor_position < 1
					@cursor_position = 1
				elsif @cursor_position > @page_height_total
					@cursor_position = @page_height_total
				end
				
				#puts "cursor: #{@cursor_position} (#{@cursor_position_old}) <=#{cursor_position_max} (#{@page_height_total})  #{cds}"
				
				calc_page
			end
			
			def cursor_position
				@cursor_position
			end
			
			private
			
			def calc_page
				# @page.each do |cell|
				# 	#puts "hide: '#{cell.name}'"
				# 	cell.is_visible = false
				# end
				
				page_end_old = @page_begin + @page_height - 1
				#puts "page old #{@page_begin} (#{@page_height}) #{page_end_old}"
				
				# -1 up
				#  0 unchanged
				# +1 down
				pds = '='
				page_direction = 0
				if @cursor_position > page_end_old
					page_direction = 1
					pds = 'v'
				elsif @cursor_position < @page_begin
					page_direction = -1
					pds = '^'
				end
				
				page_end = 0
				if page_direction == 1
					@page_begin = @cursor_position - @page_height + 1
				elsif page_direction == -1
					@page_begin = @cursor_position
				else
				end
				
				page_end = @page_begin + @page_height - 1
				
				#puts "page new #{@page_begin} #{page_end} #{pds}"
			end
			
			def render_cells
				y_pos = 0
				
				if !@header_cell_view.nil?
					@header_cell_view.is_visible = true
					y_pos += @header_cell_view.height + @header_cell_view.position.y
				end
				
				#puts "render_cells y #{y_pos}"
				#puts "render_cells p #{@page_begin}"
				
				@table.position = Point.new(0, y_pos)
				@table.offset = Point.new(0, @page_begin - 1)
			end
			
		end
		
	end
end
