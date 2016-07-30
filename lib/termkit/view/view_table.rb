
module TheFox
	module TermKit
		
		class TableView < View
			
			def initialize
				super()
				
				#puts 'TableView->initialize'
				
				@header_cell_view = nil
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
			
		end
		
	end
end
