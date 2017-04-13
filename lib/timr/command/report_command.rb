
require 'csv'

module TheFox
	module Timr
		module Command
			
			# This Command is very similar to LogCommand. By default it prints all [Tasks](rdoc-ref:TheFox::Timr::Model::Task) of the current month.
			class ReportCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/report.1'
				
				def initialize(argv = Array.new)
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					@tasks_opt = false
					@tracks_opt = false
					@from_opt = nil
					@to_opt = nil
					# @billed_opt = false
					# @unbilled_opt = false
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
						when '-t', '--tracks'
							@tracks_opt = true
						
						# when '--billed'
						# 	@billed_opt = true
						# when '--unbilled'
						# 	@unbilled_opt = true
						
						when '--csv'
							@csv_opt = argv.shift
							if !@csv_opt
								raise ReportCommandError, 'Invalid value for --csv option.'
							end
						when '-f', '--force' # -f inofficial, maybe used for --file?
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
					
					# @billed_resolved_opt = nil
					# if @billed_opt || @unbilled_opt
					# 	if @billed_opt
					# 		@billed_resolved_opt = true
					# 	elsif @unbilled_opt
					# 		@billed_resolved_opt = false
					# 	end
					# end
					
					@filter_options = {
						:format => '%y-%m-%d %H:%M',
						:from => @from_opt,
						:to => @to_opt,
						# :billed => @billed_resolved_opt,
					}
					@csv_filter_options = {
						:format => '%F %T %z',
						:from => @from_opt,
						:to => @to_opt,
					}
					
					if @csv_opt
						if @csv_opt == '-'
							# OK
						else
							@csv_opt = Pathname.new(@csv_opt).expand_path
						end
					end
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					if @csv_opt
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
							{:format => '%7s', :label => 'UNB', :padding_left => ' ', :padding_right => ' '},
							#{:format => '%3s', :label => 'TRC'},
							{:format => '%-6s', :label => 'TASK', :padding_right => ' '},
						],
					}
					table = Table.new(table_options)
					
					totals = {
						:duration => Duration.new,
						:unbilled_duration => Duration.new,
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
						unbilled_duration = task.unbilled_duration(@filter_options)
						
						# Global Duration Sum
						totals[:duration] += duration
						totals[:unbilled_duration] += unbilled_duration
						
						# Task Begin DateTime
						bdt = task.begin_datetime(@filter_options)
						
						# Task End DateTime
						edt = task.end_datetime(@filter_options)
						
						# Determine First Begin DateTime of the table.
						if bdt && (!totals[:begin_datetime] || bdt < totals[:begin_datetime])
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if edt && (!totals[:end_datetime] || edt > totals[:end_datetime])
							totals[:end_datetime] = edt
						end
						
						table << [
							totals[:task_c],
							task.begin_datetime_s(@filter_options),
							task.end_datetime_s(@filter_options),
							duration.to_human,
							unbilled_duration.to_human,
							# tracks_c,
							'%s %s' % [task.short_id, task.foreign_id ? task.foreign_id : task.name(15)]
						]
					end
					
					table << []
					
					totals[:begin_datetime_s] = totals[:begin_datetime] ? totals[:begin_datetime].localtime.strftime(@filter_options[:format]) : '---'
					
					totals[:end_datetime_s] = totals[:end_datetime] ? totals[:end_datetime].localtime.strftime(@filter_options[:format]) : '---'
					
					# Add totals to the bottom.
					table << [
						nil, # task_c
						totals[:begin_datetime_s],
						totals[:end_datetime_s],
						totals[:duration].to_human, # duration
						totals[:unbilled_duration].to_human, # duration
						# totals[:tracks_c],
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
						if bdt && (!totals[:begin_datetime] || bdt < totals[:begin_datetime])
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if edt && (!totals[:end_datetime] || edt > totals[:end_datetime])
							totals[:end_datetime] = edt
						end
						
						# Get Task from Track.
						task = track.task
						
						table << [
							totals[:tracks_c],
							track.begin_datetime_s(@filter_options),
							track.end_datetime_s(@filter_options),
							duration.to_human,
							'%s' % [task.foreign_id ? task.foreign_id : task.short_id],
							'%s %s' % [track.short_id, track.title(15)],
						]
					end
					
					table << []
					
					totals[:begin_datetime_s] = totals[:begin_datetime] ? totals[:begin_datetime].localtime.strftime(@filter_options[:format]) : '---'
					
					totals[:end_datetime_s] = totals[:end_datetime] ? totals[:end_datetime].localtime.strftime(@filter_options[:format]) : '---'
					
					# Add totals to the bottom.
					table << [
						nil, # task_c
						totals[:begin_datetime_s],
						totals[:end_datetime_s],
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
						:row_c => 0,
						
						:duration => Duration.new,
						:estimation => Duration.new,
						:remaining_time => Duration.new,
						:billed_duration => Duration.new,
						:unbilled_duration => Duration.new,
						
						:tracks_c => 0,
						:billed_tracks_c => 0,
						:unbilled_tracks_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					csv_options = {
						:headers => [
							'ROW_NO',
							
							'TASK_ID',
							'TASK_FOREIGN_ID',
							'TASK_NAME',
							
							'TASK_BEGIN_DATETIME',
							'TASK_END_DATETIME',
							
							'TASK_DURATION_HUMAN',
							'TASK_DURATION_SECONDS',
							
							'TASK_ESTIMATION_HUMAN',
							'TASK_ESTIMATION_SECONDS',
							'TASK_REMAINING_TIME_HUMAN',
							'TASK_REMAINING_TIME_SECONDS',
							
							'TASK_BILLED_DURATION_HUMAN',
							'TASK_BILLED_DURATION_SECONDS',
							'TASK_UNBILLED_DURATION_HUMAN',
							'TASK_UNBILLED_DURATION_SECONDS',
							
							'TASK_TRACK_COUNT',
							'TASK_BILLED_TRACK_COUNT',
							'TASK_UNBILLED_TRACK_COUNT',
							
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
						billed_tracks_c = task.tracks({:billed => true}).count
						unbilled_tracks_c = task.tracks({:billed => false}).count
						
						# Global Tracks Count
						totals[:tracks_c] += tracks_c
						totals[:billed_tracks_c] += billed_tracks_c
						totals[:unbilled_tracks_c] += unbilled_tracks_c
						
						# Task Duration
						duration = task.duration(@csv_filter_options)
						estimation = task.estimation
						remaining_time = task.remaining_time
						billed_duration = task.billed_duration(@csv_filter_options)
						unbilled_duration = task.unbilled_duration(@csv_filter_options)
						
						# Global Duration Sum
						if duration
							totals[:duration] += duration
						end
						if estimation
							totals[:estimation] += estimation
						end
						if remaining_time
							totals[:remaining_time] += remaining_time
						end
						if billed_duration
							totals[:billed_duration] += billed_duration
						end
						if unbilled_duration
							totals[:unbilled_duration] += unbilled_duration
						end
						
						# Task Begin DateTime
						bdt = task.begin_datetime(@csv_filter_options)
						
						# Task End DateTime
						edt = task.end_datetime(@csv_filter_options)
						
						# Determine First Begin DateTime of the table.
						if bdt && (!totals[:begin_datetime] || bdt < totals[:begin_datetime])
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if edt && (!totals[:end_datetime] || edt > totals[:end_datetime])
							totals[:end_datetime] = edt
						end
						
						csv << [
							totals[:row_c],
							
							task.id,
							task.foreign_id,
							task.name,
							
							task.begin_datetime_s(@csv_filter_options),
							task.end_datetime_s(@csv_filter_options),
							
							duration ? duration.to_human : '---',
							duration ? duration.to_i : 0,
							estimation ? estimation.to_human : '---',
							estimation ? estimation.to_i : 0,
							remaining_time ? remaining_time.to_human : '---',
							remaining_time ? remaining_time.to_i : 0,
							billed_duration ? billed_duration.to_human : '---',
							billed_duration ? billed_duration.to_i : 0,
							unbilled_duration ? unbilled_duration.to_human : '---',
							unbilled_duration ? unbilled_duration.to_i : 0,
							
							tracks_c,
							billed_tracks_c,
							unbilled_tracks_c,
						]
					end
					
					totals[:begin_datetime_s] = totals[:begin_datetime] ? totals[:begin_datetime].localtime.strftime(@csv_filter_options[:format]) : '---'
					
					totals[:end_datetime_s] = totals[:end_datetime] ? totals[:end_datetime].localtime.strftime(@csv_filter_options[:format]) : '---'
					
					totals[:row_c] += 1
					csv << [
						totals[:row_c],
						
						'TOTAL',
						nil,
						nil,
						
						totals[:begin_datetime_s],
						totals[:end_datetime_s],
						
						totals[:duration] ? totals[:duration].to_human : '---',
						totals[:duration] ? totals[:duration].to_i : 0,
						totals[:estimation] ? totals[:estimation].to_human : '---',
						totals[:estimation] ? totals[:estimation].to_i : 0,
						totals[:remaining_time] ? totals[:remaining_time].to_human : '---',
						totals[:remaining_time] ? totals[:remaining_time].to_i : 0,
						totals[:billed_duration] ? totals[:billed_duration].to_human : '---',
						totals[:billed_duration] ? totals[:billed_duration].to_i : 0,
						totals[:unbilled_duration] ? totals[:unbilled_duration].to_human : '---',
						totals[:unbilled_duration] ? totals[:unbilled_duration].to_i : 0,
						
						totals[:tracks_c],
						totals[:billed_tracks_c],
						totals[:unbilled_tracks_c],
					]
					
					csv.close
				end
				
				def export_tracks_csv
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
						:billed_duration => Duration.new,
						:unbilled_duration => Duration.new,
						:row_c => 0,
						
						:begin_datetime => nil,
						:end_datetime   => nil,
					}
					
					csv_options = {
						:headers => [
							'ROW_NO',
							
							'TASK_ID',
							'TASK_FOREIGN_ID',
							'TASK_NAME',
							
							'TRACK_ID',
							'TRACK_TITLE',
							
							'TRACK_BEGIN_DATETIME',
							'TRACK_END_DATETIME',
							
							'TRACK_DURATION_HUMAN',
							'TRACK_DURATION_SECONDS',
							'TRACK_BILLED_DURATION_HUMAN',
							'TRACK_BILLED_DURATION_SECONDS',
							'TRACK_UNBILLED_DURATION_HUMAN',
							'TRACK_UNBILLED_DURATION_SECONDS',
							'TRACK_IS_BILLED',
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
						billed_duration = track.billed_duration(@csv_filter_options)
						unbilled_duration = track.unbilled_duration(@csv_filter_options)
						
						# Global Duration Sum
						if duration
							totals[:duration] += duration
						end
						if billed_duration
							totals[:billed_duration] += billed_duration
						end
						if unbilled_duration
							totals[:unbilled_duration] += unbilled_duration
						end
						
						# Get Task from Track.
						task = track.task
						
						# Track Begin DateTime
						bdt = track.begin_datetime(@csv_filter_options)
						
						# Track End DateTime
						edt = track.end_datetime(@csv_filter_options)
						
						# Determine First Begin DateTime of the table.
						if bdt && (!totals[:begin_datetime] || bdt < totals[:begin_datetime])
							totals[:begin_datetime] = bdt
						end
						
						# Determine Last End DateTime of the table.
						if edt && (!totals[:end_datetime] || edt > totals[:end_datetime])
							totals[:end_datetime] = edt
						end
						
						csv << [
							totals[:row_c],
							
							task.id,
							task.foreign_id,
							task.name,
							
							track.id,
							track.title,
							track.begin_datetime_s(@csv_filter_options),
							track.end_datetime_s(@csv_filter_options),
							
							duration ? duration.to_human : '---',
							duration ? duration.to_i : 0,
							billed_duration ? billed_duration.to_human : '---',
							billed_duration ? billed_duration.to_i : 0,
							unbilled_duration ? unbilled_duration.to_human : '---',
							unbilled_duration ? unbilled_duration.to_i : 0,
							
							track.is_billed.to_i,
						]
					end
					
					totals[:begin_datetime_s] = totals[:begin_datetime] ? totals[:begin_datetime].localtime.strftime(@csv_filter_options[:format]) : '---'
					
					totals[:end_datetime_s] = totals[:end_datetime] ? totals[:end_datetime].localtime.strftime(@csv_filter_options[:format]) : '---'
					
					totals[:row_c] += 1
					csv << [
						totals[:row_c],
						'TOTAL',
						
						nil,
						nil,
						nil,
						
						nil,
						
						totals[:begin_datetime_s],
						totals[:end_datetime_s],
						
						totals[:duration] ? totals[:duration].to_human : '---',
						totals[:duration] ? totals[:duration].to_i : 0,
						totals[:billed_duration] ? totals[:billed_duration].to_human : '---',
						totals[:billed_duration] ? totals[:billed_duration].to_i : 0,
						totals[:unbilled_duration] ? totals[:unbilled_duration].to_human : '---',
						totals[:unbilled_duration] ? totals[:unbilled_duration].to_i : 0,
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
					puts '    -d, --day   <date>          A single day from 00:00 to 23:59.'
					puts '    -m, --month <[YYYY-]MM>     A single month from 01 to 31.'
					puts '    -y, --year  [<YYYY>]        A single year from 01-01 to 12-31.'
					puts '    -a, --all                   All.'
					puts '    --tasks                     Export Tasks (default)'
					puts '    --tracks                    Export Tracks'
					# puts '    --billed                    Filter only Tasks/Tracks which are billed.'
					# puts '    --unbilled                  Filter only Tasks/Tracks which are not billed.'
					puts "    --csv <path>                Export as CSV file. Use '--csv -' to use STDOUT."
					puts "    --force                     Force overwrite file."
					puts
					puts 'For column descriptions see man page:'
					puts "'timr help report'"
					puts
					HelpCommand.print_datetime_help
					puts
				end
				
			end # class TrackCommand
			
		end # module Command
	end # module Timr
end # module TheFox
