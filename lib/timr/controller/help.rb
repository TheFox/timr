
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
				# @table_view.size = Size.new(5, 3)
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
					when 258
						@table_view.cursor_down
						@table_view.refresh
					when 259
						@table_view.cursor_up
						@table_view.refresh
					else
						raise Exception::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
					end
					
					if !@app.nil? && !@app.logger.nil?
						@app.logger.debug("HelpViewController -- table p=#{@table_view.cursor_position} r=#{@table_view.needs_rendering? ? 'Y' : 'N'} d=#{@table_view.cursor_direction} rb=#{@table_view.page_begin} re=#{@table_view.page_end} ph=#{@table_view.page_height} c=#{@table_view.highlighted_cell}")
					end
				else
					raise Exception::UnhandledEventException.new(event), "Unhandled event: #{event}"
				end
			end
			
		end
		
	end
end
