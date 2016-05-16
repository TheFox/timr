
require 'curses'
require 'time'
require 'fileutils'
require 'yaml/store'
require 'thefox-ext'

module TheFox
	module Timr
		
		class Timr
			
			#include Curses
			
			def initialize(base_dir_path, config_path = nil)
				@base_dir_path = File.expand_path(base_dir_path)
				@base_dir_name = File.basename(@base_dir_path)
				@data_dir_path = "#{@base_dir_path}/data"
				@config_path = config_path
				
				puts "base:   #{@base_dir_path}"
				puts "name:   #{@base_dir_name}"
				puts "data:   #{@data_dir_path}"
				puts "config: #{@config_path}"
				
				@stack = Stack.new
				@tasks = {}
				@last_write = nil
				@config = {
					'clock' => {
						'default' => '%F %R',
						'large' => '%F %T',
						'short' => '%R',
					},
				}
				
				config_read
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
			
			def config_read(path = @config_path)
				if !path.nil? && File.exist?(path)
					content = YAML::load_file(path)
					@config.merge_recursive!(content)
				end
			end
			
			def init_dirs
				if !Dir.exist?(@base_dir_path)
					FileUtils.mkdir_p(@base_dir_path)
				end
				if !Dir.exist?(@data_dir_path)
					FileUtils.mkdir_p(@data_dir_path)
				end
			end
			
			def tasks_load
				Dir.chdir(@data_dir_path) do
					Dir['task_*.yml'].each do |file_name|
						#puts "file: '#{file_name}'"
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
			
			def tasks_save(print_status = false)
				@last_write = Time.now
				if print_status
					ui_status_text("Store files ... #{Time.now.strftime('%T')}")
				end
				Dir.chdir(@data_dir_path) do
					@tasks.each do |task_id, task|
						task.save_to_file('.')
					end
				end
				if print_status
					ui_status_text("Files stored. #{Time.now.strftime('%T')}")
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
				Curses.init_pair(Curses::COLOR_GREEN, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
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
			
			def ui_status_text(text = nil, attrn = Curses::A_NORMAL)
				line_nr = Curses.lines - 1
				
				Curses.setpos(line_nr, 0)
				Curses.clrtoeol
				if !text.nil?
					Curses.setpos(line_nr, COL)
					Curses.attron(attrn) do
						Curses.addstr(text)
					end
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
				
				Curses.attron(Curses.color_pair(Curses::COLOR_GREEN) | Curses::A_NORMAL) do
					if init
						Curses.setpos(line_nr, 0)
						Curses.clrtoeol
						Curses.addstr(' ' * Curses.cols)
					end
					
					Curses.setpos(line_nr, COL)
					if @stack.has_task?
						status = @stack.task.status
						track_begin_time_s = '--:--'
						if @stack.task.has_track?
							track_begin_time_s = @stack.task.track.begin_time.strftime('%R')
						end
						run_time_track = '%4d:%02d:%02d' % @stack.task.run_time_track
						run_time_total = '%4d:%02d:%02d' % @stack.task.run_time_total
						
						Curses.addstr("#{status} #{track_begin_time_s} #{run_time_track} #{run_time_total}")
					else
						Curses.addstr(TASK_NO_TASK_LOADED_CHAR)
					end
					
					if Curses.cols > MIN_COLS
						time_format = @config['clock']['default']
						if Curses.cols <= 50
							time_format = nil
						elsif Curses.cols <= 60
							time_format = @config['clock']['short']
						elsif Curses.cols > 80
							time_format = @config['clock']['large']
						end
						if !time_format.nil?
							time_str = Time.now.strftime(time_format)
							Curses.setpos(line_nr, Curses.cols - time_str.length - 1)
							Curses.addstr(time_str)
						end
					end
				end
				
				Curses.refresh
			end
			
			def ui_window_show(window)
				@window = window
				ui_window_refresh
			end
			
			def ui_window_refresh
				if !@window.nil?
					line_nr = 1
					@window.content_refresh
					max_line_len = Curses.cols - 2
					@window.page.each do |line_object|
						line_text = ''
						if line_object.is_a?(Task) || line_object.is_a?(Track)
							line_text = line_object.to_list_s
						else
							line_text = line_object.to_s
						end
						
						if line_text.length > max_line_len
							cut = line_text.length - max_line_len + 4
							line_text = "#{line_text[0..-cut]}..."
						end
						
						Curses.setpos(line_nr, 0)
						Curses.clrtoeol
						
						if @window.has_cursor?
							if line_nr == @window.cursor
								Curses.setpos(line_nr, 0)
								Curses.attron(Curses.color_pair(Curses::COLOR_BLUE) | Curses::A_BOLD) do
									Curses.addstr(' ' * COL + line_text + ' ' * (Curses.cols - line_text.length - COL))
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
						
						if $DEBUG
							Curses.refresh
							sleep 0.2
						end
					end
					
					window_page_length = @window.page_length
					content_length = ui_content_length
					if window_page_length < content_length
						((window_page_length + 1)..content_length).to_a.each do |line_nr|
							Curses.setpos(line_nr, 0)
							Curses.clrtoeol
							if $DEBUG
								Curses.addstr("-- CLEAR -- #{line_nr} #{Time.now.strftime('%T')}")
								Curses.refresh
								sleep 0.1
							end
						end
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
				
				update_content_length
				window_content_changed
				ui_stack_lines_refresh
				ui_window_refresh
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
			
			def task_apply_pop
				if @stack.pop
					update_content_length
					#window_content_changed
					ui_refresh
				end
			end
			
			# Update only Windows which shows the data. For example,
			# if a task is created all Windows needs to know this,
			# and only Windows which are using the tasks.
			# Not only the length of the rows can change, but also
			# the actual an change.
			def window_content_changed
				@window_tasks.content_changed
				@window_timeline.content_changed
			end
			
			def write_all_data
				if @last_write.nil?
					@last_write = Time.now
				else
					if Time.now - @last_write >= 300
						tasks_save(true)
					end
				end
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
						ui_status_text("Window size: #{Curses.cols}x#{Curses.lines}")
						
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
						
						if !task.nil? # && @stack.task != task
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
						ui_status_text
					when 'n'
						task_name = ui_status_input('New task: ')
						if task_name.nil?
							ui_status_text('Aborted.')
						else
							task = Task.new
							task.name = task_name
							task.save_to_file(@data_dir_path)
							
							task_apply_replace_stack(task)
							
							ui_status_text("Task '#{task_name}' created.")
						end
					when 't'
						task_name = ui_status_input('New task: ')
						if task_name.nil?
							ui_status_text('Aborted.')
						else
							task = Task.new
							task.name = task_name
							task.save_to_file(@data_dir_path)
							
							@tasks[task.id] = task
							
							update_content_length
							window_content_changed
							ui_stack_lines_refresh
							ui_window_refresh
							
							ui_status_text("Task '#{task_name}' created.")
						end
					when 'x'
						@stack.task.stop if @stack.has_task?
						window_content_changed
						ui_refresh
					when 'c'
						@stack.task.toggle if @stack.has_task?
						window_content_changed
						ui_refresh
					when 'v'
						task_apply_pop
					when 'f'
						task_apply_stack_pop_all
					when 'h', '?'
						ui_window_show(@window_help)
					when 'z' # Test Windows
						ui_window_show(@window_test)
					when '1'
						ui_window_show(@window_timeline)
					when '2'
						ui_window_show(@window_tasks)
					when 'w'
						tasks_save(true)
					when 'q'
						break
					when nil
						# Do some work.
						ui_status_line
						write_all_data
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
