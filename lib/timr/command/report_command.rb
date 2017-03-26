
require 'csv'

module TheFox
	module Timr
		module Command
			
			# This Command is very similar to LogCommand. By default it prints all Tasks of the current month.
			class ReportCommand < Command
				
				include TheFox::Timr::Error
				
				def initialize(argv = [])
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					@tasks_opt = false
					@tracks_opt = false
					@from_opt = nil
					@to_opt = nil
					@csv_opt = nil
					@force_opt = false
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						
						when '-d', '--day'
							@from_opt, @to_opt = DateTimeHelper.parse_day_argv(argv)
						when '-m', '--month'
							@from_opt, @to_opt = DateTimeHelper.parse_month_argv(argv)
						when '-y', '--year'
							@from_opt, @to_opt = DateTimeHelper.parse_year_argv(argv)
						
						when '-a', '--all'
							@from_opt = Time.parse('1970-01-01 00:00:00')
							@to_opt   = Time.parse('2099-12-31 23:59:59')
						
						when '--tasks'
							@tasks_opt = true
						when '--tracks'
							@tracks_opt = true
						
						when '--csv'
							@csv_opt = argv.shift
							if !@csv_opt
								raise ReportCommandError, 'Invalid value for --csv option.'
							end
						when '--force'
							@force_opt = true
						
						else
							raise ReportCommandError, "Unknown argument '#{arg}'. See 'timr report --help'."
						end
					end
					
					today = Date.today
					unless @from_opt
						@from_opt = Time.new(today.year, today.month, 1, 0, 0, 0)
					end
					unless @to_opt
						month_end = Date.new(today.year, today.month, -1)
						@to_opt = Time.new(today.year, today.month, month_end.day, 23, 59, 59)
					end
					
					@filter_options = {:format => '%y-%m-%d %H:%M', :from => @from_opt, :to => @to_opt}
					@csv_filter_options = {:format => '%Y-%m-%d %H:%M', :from => @from_opt, :to => @to_opt}
					
					if @csv_opt
						if @csv_opt == '-'
							#@csv_opt = STDOUT
						else
							@csv_opt = Pathname.new(@csv_opt).expand_path
						end
						
						# puts "csv opt: #{@csv_opt}" # @TODO remove
					end
				end
				
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					if @csv_opt
						puts "CSV: task=#{@tasks_opt} track=#{@tracks_opt}"
						
						if @tasks_opt
							export_tasks_csv
						elsif @tracks_opt
							export_tracks_csv
						else
							export_tasks_csv
						end
					else
						if @tasks_opt
							print_task_table
						elsif @tracks_opt
							print_track_table
						else
							print_task_table
						end
					end
				end
				
				private
				
				def print_task_table
					puts "From #{@from_opt.strftime('%F %T %z')}"
					puts "  To #{@to_opt.strftime('%F %T %z')}"
					puts
					
					table_options = {
						:headings => [
							{:format => '%3s', :label => '###'},
							{:format => '%-14s', :label => 'START', :padding_left => ' ', :padding_right => ' '},
							{:format => '%-14s', :label => 'END', :padding_left => ' ', :padding_right => ' '},
							{:format => '%7s', :label => 'DUR', :padding_left => ' ', :padding_right => ' '},
							{:format => '%3s', :label => 'TRC'},
							{:format => '%-6s', :label => 'TASK', :padding_right => ' '},
						],
					}
					table = Table.new(table_options)
					
					totals = {
						:duration => Duration.new,
						:task_c => 0,
						:tracks_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					table_has_rows = false
					
					filtered_tasks.each do |task|
						table_has_rows = true
						totals[:task_c] += 1
						
						tracks = task.tracks
						
						# Task Tracks Count
						tracks_c = tracks.count
						
						# Global Tracks Count
						totals[:tracks_c] += tracks_c
						
						# Task Duration
						duration = task.duration(@filter_options)
						
						# Global Duration Sum
						totals[:duration] += duration
						
						# Task Begin DateTime
						bdt = task.begin_datetime(@filter_options)
						
						# Task End DateTime
						edt = task.end_datetime(@filter_options)
						
						# Determine First Begin DateTime of the table.
						if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if !totals[:end_datetime] || edt > totals[:end_datetime]
							totals[:end_datetime] = edt
						end
						
						table << [
							totals[:task_c],
							task.begin_datetime_s(@filter_options),
							task.end_datetime_s(@filter_options),
							duration.to_human,
							tracks_c,
							'%s %s' % [task.short_id, task.name(15)]
						]
					end
					
					table << []
					
					# Add totals to the bottom.
					table << [
						nil, # task_c
						totals[:begin_datetime].strftime(@filter_options[:format]),
						totals[:end_datetime].strftime(@filter_options[:format]),
						totals[:duration].to_human, # duration
						totals[:tracks_c],
						'TOTAL', # task
					]
					
					if table_has_rows
						puts table
					else
						puts 'No tasks found.'
					end
				end
				
				def print_track_table
					puts "From #{@from_opt.strftime('%F %T %z')}"
					puts "  To #{@to_opt.strftime('%F %T %z')}"
					puts
					
					table_options = {
						:headings => [
							{:format => '%3s', :label => '###'},
							{:format => '%-14s', :label => 'START', :padding_left => ' ', :padding_right => ' '},
							{:format => '%-14s', :label => 'END', :padding_left => ' ', :padding_right => ' '},
							{:format => '%7s', :label => 'DUR', :padding_left => ' ', :padding_right => ' '},
							{:format => '%-6s', :label => 'TASK', :padding_right => ' '},
							{:format => '%-6s', :label => 'TRACK', :padding_right => ' '},
						],
					}
					table = Table.new(table_options)
					
					totals = {
						:duration => Duration.new,
						:tracks_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					table_has_rows = false
					@timr.tracks(@filter_options).each do |track_id, track|
						table_has_rows = true
						totals[:tracks_c] += 1
						
						# Track Duration
						duration = track.duration(@filter_options)
						
						# Global Duration Sum
						totals[:duration] += duration
						
						# Track Begin DateTime
						bdt = track.begin_datetime(@filter_options)
						
						# Track End DateTime
						edt = track.end_datetime(@filter_options)
						
						# Determine First Begin DateTime of the table.
						if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if !totals[:end_datetime] || edt > totals[:end_datetime]
							totals[:end_datetime] = edt
						end
						
						# Get Task from Track.
						task = track.task
						
						table << [
							totals[:tracks_c],
							track.begin_datetime_s(@filter_options),
							track.end_datetime_s(@filter_options),
							duration.to_human,
							'%s' % [task.short_id],
							'%s %s' % [track.short_id, track.title(15)],
						]
					end
					
					table << []
					
					# Add totals to the bottom.
					table << [
						nil, # task_c
						totals[:begin_datetime].strftime(@filter_options[:format]),
						totals[:end_datetime].strftime(@filter_options[:format]),
						totals[:duration].to_human, # duration
						'TOTAL', # task
						nil, # track
					]
					
					if table_has_rows
						puts table
					else
						puts 'No tracks found.'
					end
				end
				
				def export_tasks_csv
					# puts "xxxxxx" # @TODO remove
					
					if @csv_opt == '-'
						csv_file_handle = STDOUT
					else
						if @csv_opt.exist? && !@force_opt
							raise ReportCommandError, "File '#{@csv_opt}' already exist. Use --force to overwrite it."
						end
						#csv_file_handle = @csv_opt.to_s
						csv_file_handle = File.open(@csv_opt, 'wb')
					end
					
					totals = {
						:duration => Duration.new,
						:row_c => 0,
						:tracks_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					csv_options = {
						:headers => [
							'ROW_NO',
							
							'TASK_ID',
							'TASK_NAME',
							
							'TASK_BEGIN_DATETIME',
							'TASK_END_DATETIME',
							
							'TASK_DURATION_HUMAN',
							'TASK_DURATION_SECONDS',
							
							'TASK_TRACK_COUNT',
							
							# 'TASK_SHORTEST_TRACK_DURATION_HUMAN', # @TODO shortest longest track duration
							# 'TASK_SHORTEST_TRACK_DURATION_SECONDS',
							# 'TASK_LONGEST_TRACK_DURATION_HUMAN',
							# 'TASK_LONGEST_TRACK_DURATION_SECONDS',
						],
						:write_headers => true,
						:skip_blanks => true,
						#:force_quotes => true,
					}
					csv = CSV.new(csv_file_handle, csv_options)
					filtered_tasks.each do |task|
						totals[:row_c] += 1
						
						tracks = task.tracks
						
						# Task Tracks Count
						tracks_c = tracks.count
						
						# Global Tracks Count
						totals[:tracks_c] += tracks_c
						
						# Task Duration
						duration = task.duration(@csv_filter_options)
						
						# Global Duration Sum
						totals[:duration] += duration
						
						# Task Begin DateTime
						bdt = task.begin_datetime(@csv_filter_options)
						
						# Task End DateTime
						edt = task.end_datetime(@csv_filter_options)
						
						# Determine First Begin DateTime of the table.
						if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if !totals[:end_datetime] || edt > totals[:end_datetime]
							totals[:end_datetime] = edt
						end
						
						csv << [
							totals[:row_c],
							
							task.id,
							task.name,
							
							task.begin_datetime_s(@csv_filter_options),
							task.end_datetime_s(@csv_filter_options),
							
							duration.to_human,
							duration.to_i,
							
							tracks_c,
						]
					end
					
					totals[:row_c] += 1
					csv << [
						totals[:row_c],
						
						'TOTAL',
						'TOTAL',
						
						totals[:begin_datetime].strftime(@csv_filter_options[:format]),
						totals[:end_datetime].strftime(@csv_filter_options[:format]),
						
						totals[:duration].to_human,
						totals[:duration].to_i,
						
						totals[:tracks_c],
					]
					
					csv.close
				end
				
				def export_tracks_csv
					puts "export_tracks_csv" # @TODO remove
					
					if @csv_opt == '-'
						csv_file_handle = STDOUT
					else
						if @csv_opt.exist? && !@force_opt
							raise ReportCommandError, "File '#{@csv_opt}' already exist. Use --force to overwrite it."
						end
						#csv_file_handle = @csv_opt.to_s
						csv_file_handle = File.open(@csv_opt, 'wb')
					end
					
					totals = {
						:duration => Duration.new,
						:row_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					csv_options = {
						:headers => [
							'ROW_NO',
							
							'TASK_ID',
							'TASK_NAME',
							
							'TRACK_ID',
							'TRACK_TITLE',
							'TRACK_BEGIN_DATETIME',
							'TRACK_END_DATETIME',
							'TRACK_DURATION_HUMAN',
							'TRACK_DURATION_SECONDS',
						],
						:write_headers => true,
						:skip_blanks => true,
						#:force_quotes => true,
					}
					csv = CSV.new(csv_file_handle, csv_options)
					@timr.tracks(@csv_filter_options).each do |track_id, track|
						totals[:row_c] += 1
						
						# Track Duration
						duration = track.duration(@csv_filter_options)
						
						# Global Duration Sum
						totals[:duration] += duration
						
						# Get Task from Track.
						task = track.task
						
						# Track Begin DateTime
						bdt = track.begin_datetime(@csv_filter_options)
						
						# Track End DateTime
						edt = track.end_datetime(@csv_filter_options)
						
						# Determine First Begin DateTime of the table.
						if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if !totals[:end_datetime] || edt > totals[:end_datetime]
							totals[:end_datetime] = edt
						end
						
						csv << [
							totals[:row_c],
							
							task.id,
							task.name,
							
							track.id,
							track.title,
							track.begin_datetime_s(@csv_filter_options),
							track.end_datetime_s(@csv_filter_options),
							duration.to_human,
							duration.to_i,
						]
					end
					
					totals[:row_c] += 1
					csv << [
						totals[:row_c],
						'TOTAL',
						
						'TOTAL',
						'TOTAL',
						
						'TOTAL',
						totals[:begin_datetime].strftime(@csv_filter_options[:format]),
						totals[:end_datetime].strftime(@csv_filter_options[:format]),
						totals[:duration].to_human,
						totals[:duration].to_i,
					]
					
					csv.close
				end
				
				def filtered_tasks
					# Get Tracks.
					tracks = @timr.tracks(@filter_options)
					
					# Convert Tracks to Tasks. Convert the Array to a Set removes all duplicates.
					tracks.map{ |track_id, track| track.task }.to_set
				end
				
				def help
					puts 'usage: timr report '
					puts '   or: timr report [-h|--help]'
					puts
					puts 'Options'
					puts '    -d, --day   <YYYY-MM-DD>    A single day from 00:00 to 23:59.'
					puts '    -m, --month <[YYYY-]MM>     A single month from 01 to 31.'
					puts '    -y, --year  [<YYYY>]        A single year from 01-01 to 12-31.'
					puts '    -a, --all                   All.'
					puts "    --csv <path>                Export as CSV file. Use '--csv -' to use STDOUT."
					puts
					puts 'Task Table Columns'
					puts '    START    Task Start Date'
					puts '    END      Task End Date'
					puts '    DUR      Task Duration'
					puts '    TRC      Tracks Count'
					puts '    TASK     Task ID and Name.'
					puts
					puts 'Track Table Columns'
					puts '    START    Task Start Date'
					puts '    END      Task End Date'
					puts '    DUR      Task Duration'
					puts '    TASK     Task ID'
					puts '    TRACK    Track ID and Name.'
					puts
					puts 'Task CSV Columns'
					puts '    ROW_NO                    Sequential CSV file row number.'
					puts
					puts '    TASK_ID                   Task ID'
					puts '    TASK_NAME                 Task Name'
					puts '    TASK_BEGIN_DATETIME       Begin DateTime of the first Track.'
					puts '    TASK_END_DATETIME         End DateTime of the last Track.'
					puts '    TASK_DURATION_HUMAN       Task Duration in human format: 5m 6s'
					puts '    TASK_DURATION_SECONDS     Task Duration in seconds: 306'
					puts '    TASK_TRACK_COUNT          Task Track count.'
					puts
					puts 'Track CSV Columns'
					puts '    ROW_NO                    Sequential CSV file row number.'
					puts
					puts '    TASK_ID                   Task ID'
					puts '    TASK_NAME                 Task Name'
					puts
					puts '    TRACK_ID                  Track ID'
					puts '    TRACK_TITLE               Track Title'
					puts '    TRACK_BEGIN_DATETIME      Begin DateTime'
					puts '    TRACK_END_DATETIME        End DateTime'
					puts '    TRACK_DURATION_HUMAN      Track Duration in human format: 5m 6s'
					puts '    TRACK_DURATION_SECONDS    Task Duration in seconds: 306'
					puts
					puts 'The last row in CSV files is always the total sum.'
				end
				
			end # class TrackCommand
			
		end # module Command
	end # module Timr
end # module TheFox
