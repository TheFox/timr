
module TheFox
	module Timr
		
		class HelpViewController < TheFox::TermKit::ViewController
			
			def initialize
				# view1 = TheFox::TermKit::TextView.new('HELLO WORLD')
				# view1.is_visible = true
				
				# view2 = TheFox::TermKit::TextView.new('BBB')
				# view2.position = TheFox::TermKit::Point.new(10, 5)
				# view2.is_visible = true
				
				#view1.add_subview(view2)
				
				#super(view1)
				
				header = TitleView.new
				
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
				#Curses.setpos(1, 0)
				#Curses.addstr("HELP CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(TheFox::TermKit::KeyEvent)
					case event.key
					when 'a', 's'
						#puts "#{self.class} #{event.key}"
						Curses.setpos(2, 0)
						Curses.addstr("HELP HANDLED: #{event.key}   ")
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
