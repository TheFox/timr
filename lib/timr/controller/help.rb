
module TheFox
	module Timr
		
		class HelpViewController < TheFox::TermKit::ViewController
			
			def initialize
				header = TitleView.new
				header.is_visible = true
				
				table_view = HelpTableView.new
				table_view.is_visible = true
				table_view.position = TheFox::TermKit::Point.new(0, 10)
				table_view.header_cell_view = header
				
				view = TheFox::TermKit::View.new
				view.is_visible = true
				view.add_subview(table_view)
				
				@main_view_controller = TheFox::TermKit::ViewController.new(view)
				add_subcontroller(@main_view_controller)
			end
			
			def render
				super()
				
				@main_view_controller.render
			end
			
			def handle_event(event)
				#Curses.setpos(1, 0)
				#Curses.addstr("HELP CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(TheFox::TermKit::KeyEvent)
					case event.key
					when 'a', 's'
						#puts "#{self.class} #{event.key}"
						Curses.setpos(2, 0)
						Curses.addstr("HELP HANDLED: #{event.key}   ")
					when 'x'
						Curses.setpos(2, 0)
						Curses.addstr("HELP HANDLED: #{event.key}   ")
						
						@main_view_controller.view.is_visible = false
					else
						raise TheFox::TermKit::Exception::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
					end
				else
					raise TheFox::TermKit::Exception::UnhandledEventException.new(event), "Unhandled event: #{event}"
				end
			end
			
		end
		
	end
end
