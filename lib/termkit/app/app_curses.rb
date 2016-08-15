
require 'curses'
#require 'io/console'

module TheFox
	module TermKit
		
		CURSES_TIMEOUT = 200
		
		class CursesApp < UIApp
			
			def initialize
				@curses_timeout = CURSES_TIMEOUT
				
				@ui_inited = false
				@ui_closed = false
				
				super()
				
				#puts 'CursesApp->initialize'
			end
			
			def curses_timeout=(curses_timeout)
				@curses_timeout = curses_timeout
				Curses.timeout = @curses_timeout
			end
			
			def run_cycle
				super()
				
				#puts 'CursesApp->run_cycle'
				
				handle_user_input
			end
			
			def draw_line(point, content)
				draw_point(point, content)
			end
			
			def draw_point(point, content)
				Curses.setpos(point.y, point.x)
				Curses.addstr(content)
			end
			
			def ui_refresh
				Curses.refresh
			end
			
			def ui_max_x
				Curses.cols
			end
			
			def ui_max_y
				Curses.rows
			end
			
			protected
			
			def ui_init
				#puts "CursesApp->ui_init '#{@curses_timeout}'"
				
				raise 'ui already initialized' if @ui_inited
				@ui_inited = true
				
				super()
				
				Curses.noecho
				Curses.timeout = @curses_timeout
				Curses.curs_set(0)
				Curses.init_screen
				Curses.start_color
				Curses.use_default_colors
				Curses.crmode
				Curses.stdscr.keypad(true)
				
				Curses.init_pair(Curses::COLOR_BLUE, Curses::COLOR_WHITE, Curses::COLOR_BLUE)
				Curses.init_pair(Curses::COLOR_RED, Curses::COLOR_WHITE, Curses::COLOR_RED)
				Curses.init_pair(Curses::COLOR_GREEN, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
				
				Curses.setpos(0, 0)
				Curses.addstr('INIT OK')
				Curses.refresh
			end
			
			def ui_close
				#puts "CursesApp->ui_close"
				
				raise 'ui already closed' if @ui_closed
				@ui_closed = true
				
				Curses.setpos(10, 0)
				Curses.addstr('CLOSE   ')
				Curses.refresh
				sleep(2)
				
				Curses.refresh
				Curses.stdscr.clear
				Curses.stdscr.refresh
				Curses.stdscr.close
				Curses.close_screen
			end
			
			private
			
			def handle_user_input
				key_down(Curses.getch)
				#key_down(IO.console.getch)
			end
			
		end
		
	end
end
