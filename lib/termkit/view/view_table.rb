
module TheFox
	module TermKit
		
		class TableView < View
			
			def initialize
				super()
				
				#puts 'TableView->initialize'
				
				@header_cell_view = nil
				@table_data = []
				@cells = []
				@cursor_position = nil
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
			end
			
			def table_data=(table_data)
				if !table_data.is_a?(Array)
					raise ArgumentError, "Argument is not a Array -- #{table_data.class} given"
				end
				
				@table_data = table_data
				@cells = []
				
				@table_data.each do |row|
					cell = nil
					
					case row
					when String
						text_view = TextView.new()
						text_view.is_visible = true
						text_view.text = row
						
						cell = CellTableView.new(text_view)
						cell.is_visible = true
					when CellTableView
						cell = row
					else
						raise NotImplementedError, "Class '#{row.class}' not implemented yet"
					end
					
					append_cell(cell)
				end
			end
			
			def render(area = nil)
				render_cells
				
				super(area)
			end
			
			def cursor_position=(y_pos)
				@cursor_position = y_pos
			end
			
			private
			
			def append_cell(cell)
				@cells.push(cell)
				add_subview(cell)
			end
			
			def render_cells
				y_pos = 0
				
				if !@header_cell_view.nil?
					y_pos += @header_cell_view.height + @header_cell_view.position.y
				end
				
				@cells.each do |cell|
					cell.position = Point.new(0, y_pos)
					y_pos += cell.height
				end
			end
			
		end
		
	end
end
