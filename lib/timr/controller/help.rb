
module TheFox
	module Timr
		
		class HelpController < TheFox::TermKit::Controller
			
			def initialize
				super()
				
				header = HeaderCellTableView.new
				
				table_view = TheFox::TermKit::TableView.new
				table_view.header_cell_view = header
				
				@main_view_controller = TheFox::TermKit::ViewController.new(table_view)
			end
			
			def active
				super()
				
				@main_view_controller.active
			end
			
			def inactive
				super()
				
				@main_view_controller.inactive
			end
			
			def handle_event(event)
				Curses.setpos(1, 0)
				Curses.addstr("HELP CONTROLLER: #{event.key}    #{event.class}")
				
				case event.key
				when 'a', 's'
					#puts "#{self.class} #{event.key}"
					Curses.setpos(0, 0)
					Curses.addstr("HANDLED: #{event.key}   ")
				else
					raise TheFox::TermKit::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
				end
			end
			
		end
		
	end
end
