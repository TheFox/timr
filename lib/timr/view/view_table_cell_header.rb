
module TheFox
	module Timr
		
		class HeaderCellTableView < TheFox::TermKit::CellTableView
			
			def initialize
				puts 'HeaderTableCellView initialize'
				
				#@title_view = TheFox::TermKit::TextView.new
				#@title_view.text = 'TABLE HEADER TEXT'
				
				
				
				view1 = TheFox::TermKit::TextView.new
				view1.text = 'ABC'
				view1.position = TheFox::TermKit::Point.new(5, 0)
				
				view2 = TheFox::TermKit::TextView.new
				view2.text = '123'
				view2.position = TheFox::TermKit::Point.new(10, 1)
				
				add_subview(view1)
				add_subview(view2)
			end
			
		end
		
	end
end
