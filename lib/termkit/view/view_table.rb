
module TheFox
	module TermKit
		
		class TableView < View
			
			def initialize
				#puts 'TableView initialize'
				
				@header_cell_view = nil
			end
			
			def header_cell_view=(header_cell_view)
				if !header_cell_view.is_a?(CellTableView)
					raise "header_cell_view is of wrong class: #{header_cell_view.class}"
				end
				
				@header_cell_view = header_cell_view
			end
			
			# def header_text=(header_text)
			# 	if @header_cell_view.nil?
			# 		@header_cell_view = TableCellView.new
			# 	end
			# end
			
		end
		
	end
end
