
require 'termkit'

module TheFox
	module Timr
		
		class HelpViewController < TheFox::TermKit::ViewController
			
			include TheFox::TermKit
			
			def initialize
				header = TextView.new("--HEADER A--")
				header.is_visible = true
				
				
				table_view = TableView.new
				# table_view.is_visible = true
				# table_view.position = Point.new(0, 5)
				# table_view.header_cell_view = header
				# table_view.table_data = ['zeile 1', 'zeile 2', 'zeile 3', 'zeile 4', 'zeile 5']
				
				view = View.new
				view.is_visible = true
				view.add_subview(table_view)
				
				super(view)
				#super(table_view)
				
				# @main_view_controller = ViewController.new(view)
				#@main_view_controller = ViewController.new(table_view)
				# add_subcontroller(@main_view_controller)
			end
			
			def render(area = nil)
				super(area)
				
				#@main_view_controller.render
			end
			
			def handle_event(event)
				#Curses.setpos(1, 0)
				#Curses.addstr("HELP CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(KeyEvent)
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
