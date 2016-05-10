
require 'curses'
require 'time'

module TheFox
	module Timr
		
		class Timr
			
			#include Curses
			
			def initialize(path)
				@base_dir_path = File.expand_path(path)
				@base_dir_name = File.basename(@base_dir_path)
				@data_dir_path = "#{@base_dir_path}/data"
				
				puts "base: #{@base_dir_path}"
				puts "name: #{@base_dir_name}"
				puts "data: #{@data_dir_path}"
				
				@stack = Stack.new
				@tasks = {}
				
				init_dirs
				tasks_load
				
				@window = nil
				@window_help = HelpWindow.new
				@window_test = TestWindow.new
				
				@window_tasks = TasksWindow.new
				@window_tasks.tasks = @tasks
				
				@window_timeline = TimelineWindow.new
				@window_timeline.tasks = @tasks
			end
			
			def init_dirs
				if !Dir.exist?(@base_dir_path)
					Dir.mkdir(@base_dir_path)
				end
				if !Dir.exist?(@data_dir_path)
					Dir.mkdir(@data_dir_path)
				end
			end
			
			def tasks_load
				Dir.chdir(@data_dir_path) do
					Dir['task_*.yml'].each do |file_name|
						puts "file: '#{file_name}'"
						task = Task.new(file_name)
						@tasks[task.id] = task
					end
				end
			end
			
			def tasks_stop
				@tasks.each do |task_id, task|
					task.stop
				end
			end
			
			def tasks_save
				Dir.chdir(@data_dir_path) do
					@tasks.each do |task_id, task|
						task.save_to_file('.')
					end
				end
			end
			
			def ui_init_curses
				Curses.noecho
				Curses.timeout = TIMEOUT
				Curses.curs_set(0)
				Curses.init_screen
				Curses.start_color
				Curses.use_default_colors
				Curses.crmode
				Curses.stdscr.keypad(true)
				
				Curses.init_pair(Curses::COLOR_BLUE, Curses::COLOR_WHITE, Curses::COLOR_BLUE)
				Curses.init_pair(Curses::COLOR_RED, Curses::COLOR_WHITE, Curses::COLOR_RED)
				Curses.init_pair(Curses::COLOR_YELLOW, Curses::COLOR_BLACK, Curses::COLOR_YELLOW)
			end
			
			def ui_title_line
				title = "#{NAME} #{VERSION} -- #{@base_dir_name}"
				if Curses.cols <= title.length + 1
					title = "#{NAME} #{VERSION}"
					if Curses.cols <= title.length + 1
						title = NAME
					end
				end
				rest = Curses.cols - title.length - COL
				
				Curses.setpos(0, 0)
				Curses.attron(Curses.color_pair(Curses::COLOR_BLUE) | Curses::A_BOLD) do
					Curses.addstr(' ' * COL + title + ' ' * rest)
				end
			end
			
			def ui_status_text(text, attrn = Curses::A_NORMAL)
				line_nr = Curses.lines - 1
				
				Curses.setpos(line_nr, 0)
				Curses.clrtoeol
				Curses.setpos(line_nr, COL)
				Curses.attron(attrn) do
					Curses.addstr(text)
				end
				Curses.refresh
			end
			
			def ui_status_text_error(text)
				ui_status_text(text, Curses.color_pair(Curses::COLOR_RED) | Curses::A_BOLD)
			end
			
			def ui_status_input(text)
				Curses.echo
				Curses.timeout = -1
				Curses.curs_set(1)
				
				ui_status_text(text)
				
				input = ''
				abort = false
				loop do
					key_pressed = Curses.getch
					case key_pressed
					when 27
						abort = true
						break
					when Curses::Key::BACKSPACE
						Curses.stdscr.delch
						input = input[0..-2]
					when 10
						break
					else
						input += key_pressed
					end
				end
				if abort
					input = nil
				end
				
				Curses.noecho
				Curses.timeout = TIMEOUT
				Curses.curs_set(0)
				
				input
			end
			
			def ui_status_line(init = false)
				line_nr = Curses.lines - 2
				
				Curses.attron(Curses.color_pair(Curses::COLOR_YELLOW) | Curses::A_NORMAL) do
					if init
						Curses.setpos(line_nr, 0)
						Curses.clrtoeol
						Curses.addstr(' ' * Curses.cols)
					end
					
					Curses.setpos(line_nr, COL)
					if @stack.has_task?
						Curses.addstr(@stack.task.status)
					else
						Curses.addstr(TASK_NO_TASK_LOADED_C)
					end
					
					if Curses.cols > MIN_COLS
						time_format = '%F %R %Z'
						if Curses.cols <= 30
							time_format = '%R'
						elsif Curses.cols <= 40
							time_format = '%m-%d %R'
						elsif Curses.cols <= 50
							time_format = '%y-%m-%d %R'
						elsif Curses.cols <= 60
							time_format = '%F %R'
						elsif Curses.cols > 80
							time_format = '%F %T %Z'
						end
						time_str = Time.now.strftime(time_format)
						Curses.setpos(line_nr, Curses.cols - time_str.length - 1)
						Curses.addstr(time_str)
					end
				end
				
				Curses.refresh
			end
			
			def ui_window_show(window)
				@window = window
				ui_window_refresh
			end
			
			def ui_window_refresh
				max_lines = ui_content_length
				(1..max_lines).each do |line_nr|
					Curses.setpos(line_nr, 0)
					Curses.clrtoeol
				end
				
				if !@window.nil?
					line_nr = 1
					@window.content_refresh
					page_length = @window.page_length
					current_line = @window.current_line
					max_line_len = Curses.cols - 2
					@window.page.each do |line_object|
						is_cursor = line_nr == @window.cursor
						
						line_text = ''
						if line_object.is_a?(Task) || line_object.is_a?(Track)
							line_text = line_object.to_list_s
						else
							line_text = line_object.to_s
						end
						
						#line_text = "#{line_text} #{is_cursor ? 'X' : ''}"
						if line_text.length > max_line_len
							cut = line_text.length - max_line_len + 4
							line_text = "#{line_text[0..-cut]}..."
						end
						
						rest = Curses.cols - line_text.length - COL
						
						if @window.has_cursor?
							if is_cursor
								Curses.setpos(line_nr, 0)
								Curses.attron(Curses.color_pair(Curses::COLOR_BLUE) | Curses::A_BOLD) do
									Curses.addstr(' ' * COL + line_text + ' ' * rest)
								end
							else
								Curses.setpos(line_nr, COL)
								Curses.addstr(line_text)
							end
						else
							Curses.setpos(line_nr, COL)
							Curses.addstr(line_text)
						end
						
						
						line_nr += 1
					end
				end
				
				Curses.refresh
			end
			
			def ui_content_length
				Curses.lines - RESERVED_LINES - @stack.length
			end
			
			def update_content_length
				cl = ui_content_length
				
				@window_help.content_length = cl
				@window_test.content_length = cl
				@window_tasks.content_length = cl
				@window_timeline.content_length = cl
			end
			
			def ui_refresh
				ui_stack_lines_refresh
				ui_window_refresh
			end
			
			def ui_refresh_all
				update_content_length
				ui_title_line
				ui_status_line(true)
				ui_refresh
			end
			
			def ui_stack_lines_refresh
				line_nr = Curses.lines - (3 + (@stack.length - 1))
				
				Curses.attron(Curses.color_pair(Curses::COLOR_BLUE)) do
					@stack.tasks_texts.reverse.each do |line_text|
						rest = Curses.cols - line_text.length - COL
						
						Curses.setpos(line_nr, 0)
						Curses.clrtoeol
						Curses.addstr(' ' * COL + line_text + ' ' * rest)
						
						line_nr += 1
					end
				end
				
				Curses.refresh
			end
			
			def task_apply(task = nil, push = false)
				if task.nil?
					@stack.pop_all
				else
					@tasks[task.id] = task
					if push
						@stack.push(task)
					else
						@stack.pop_all(task)
					end
				end
				
				window_content_changed
				ui_stack_lines_refresh
				ui_window_refresh if !push
			end
			
			def task_apply_replace_stack(task)
				task_apply(task, false)
			end
			
			def task_apply_stack_pop_all
				task_apply(nil, false)
			end
			
			def task_apply_push(task)
				task_apply(task, true)
			end
			
			def window_content_changed
				@window_tasks.content_changed
				@window_timeline.content_changed
			end
			
			def run
				ui_init_curses
				update_content_length
				ui_title_line
				ui_status_line(true)
				ui_window_show(@window_timeline)
				
				loop do
					key_pressed = Curses.getch
					
					case key_pressed
					when Curses::Key::NPAGE
						@window.next_page if !@window.nil?
						ui_window_refresh
					when Curses::Key::PPAGE
						@window.previous_page if !@window.nil?
						ui_window_refresh
					when Curses::Key::DOWN
						if !@window.nil? && @window.has_cursor?
							@window.cursor_next_line 
							
							#ui_status_text("Cursor: #{@window.cursor} c=#{ui_content_length}  l=#{@window.current_line}  pr=#{@window.page_refreshes}  cr=#{@window.content_refreshes}")
							
							ui_window_refresh
						end
					when Curses::Key::UP
						if !@window.nil? && @window.has_cursor?
							@window.cursor_previous_line
							
							#ui_status_text("Cursor: #{@window.cursor} c=#{ui_content_length}  l=#{@window.current_line}  pr=#{@window.page_refreshes}  cr=#{@window.content_refreshes}")
							
							ui_window_refresh
						end
					when Curses::Key::HOME
						@window.first_page if !@window.nil?
						ui_window_refresh
					when Curses::Key::END
						@window.last_page if !@window.nil?
						ui_window_refresh
					when Curses::Key::RESIZE
						update_content_length
						ui_status_text("Resizing: #{Curses.lines}x#{Curses.cols}")
						
						# Refreshing the complete screen while resizing
						# can make everything slower. So for fast resizing
						# comment this line.
						ui_refresh_all
					when 10
						object = @window.page_object if !@window.nil?
						
						task = nil
						if object.is_a?(Task)
							task = object
						elsif object.is_a?(Track)
							task = object.task
						end
						
						if task.nil?
							ui_status_text("Unrecognized object: #{object.class}")
						else
							task_apply_replace_stack(task)
						end
					when 'b', 'p'
						object = @window.page_object if !@window.nil?
						
						task = nil
						if object.is_a?(Task)
							task = object
						elsif object.is_a?(Track)
							task = object.task
						end
						
						if task.nil?
							ui_status_text("Unrecognized object: #{object.class}")
						else
							task_apply_push(task)
						end
					when 'r'
						ui_refresh_all
						ui_status_text('')
					when 'n'
						task_name = ui_status_input('New task: ')
						if task_name.nil?
							ui_status_text('Aborted.')
						else
							task_description = ui_status_input('Description: ')
							
							task = @stack.create(task_name, task_description)
							task_apply_replace_stack(task)
							
							ui_status_text("Task '#{task_name}' created: #{task.id}")
						end
					when 'x'
						@stack.task.stop if @stack.has_task?
					when 'c'
						@stack.task.toggle if @stack.has_task?
					when 'v'
						if @stack.pop
							window_content_changed
							ui_refresh
						end
					when 'f'
						task_apply_stack_pop_all
					when 'h', '?'
						ui_window_show(@window_help)
					when 't' # Test Windows
						ui_window_show(@window_test)
					when '1'
						ui_window_show(@window_timeline)
					when '2'
						ui_window_show(@window_tasks)
					when 'w'
						tasks_save
					when 'q'
						break
					when nil
						# Do some work.
						ui_status_line
					else
						ui_status_text_error("Invalid key '#{key_pressed}' (#{Curses.keyname(key_pressed)})")
					end
				end
			end
			
			def close
				Curses.stdscr.clear
				Curses.stdscr.refresh
				Curses.stdscr.close
				
				Curses.close_screen
				
				tasks_stop
				tasks_save
			end
			
		end
		
	end
end
