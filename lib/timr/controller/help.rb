
require 'termkit'

module TheFox
	module Timr
		
		class HelpViewController < TheFox::TermKit::ViewController
			
			include TheFox::TermKit
			
			def initialize
				header = TextView.new("##########--HEADER B--")
				header.is_visible = true
				
				@table_view = TableView.new
				@table_view.is_visible = true
				@table_view.size = Size.new(5, 3)
				@table_view.position = Point.new(0, 2)
				@table_view.header = header
				@table_view.data = ['zeile 1a', 'zeile 2b', 'zeile 3c', 'zeile 4d', 'zeile 5e']
				@table_view.refresh
				
				view = View.new
				view.is_visible = true
				view.add_subview(@table_view)
				
				super(view)
			end
			
			def handle_event(event)
				#Curses.setpos(1, 0)
				#Curses.addstr("HELP CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(KeyEvent)
					# @app.logger.debug("HelpViewController -- key event: #{event.key}")
					
					case event.key
					when 'a', 's'
						#puts "#{self.class} #{event.key}"
						#Curses.setpos(2, 0)
						#Curses.addstr("HELP HANDLED: #{event.key}   ")
					when 'x'
						#Curses.setpos(2, 0)
						#Curses.addstr("HELP HANDLED: #{event.key}   ")
						
						# @main_view_controller.view.is_visible = false
					else
						raise Exception::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
					end
				else
					raise Exception::UnhandledEventException.new(event), "Unhandled event: #{event}"
				end
			end
			
		end
		
	end
end
