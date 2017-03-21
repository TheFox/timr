
module TheFox
	module Timr
		
		class ReportCommand < Command
			
			def initialize(argv = [])
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				@tasks_opt = false
				@tracks_opt = false
				@from_opt = nil
				@to_opt = nil
				@csv_opt = nil
				
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
					
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr report --help'."
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
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				if @tasks_opt
					print_task_table
				elsif @tracks_opt
					print_track_table
				else
					print_task_table
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
						{:format => '%3s', :label => 'TrC'},
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
					
					# :begin_datetime => Time.parse('2099-12-31 23:59:59'),
					# :end_datetime   => Time.parse('1970-01-01 00:00:00'),
					
					# :begin_datetime => Time.parse('1970-01-01 00:00:00'),
					# :end_datetime   => Time.parse('2099-12-31 23:59:59'),
				}
				
				table_has_rows = false
				
				filtered_tasks.each do |task|
					table_has_rows = true
					totals[:task_c] += 1
					
					tracks = task.tracks
					tracks_c = tracks.count
					totals[:tracks_c] += tracks_c
					
					duration = task.duration(@filter_options)
					totals[:duration] += duration
					
					bdt = task.begin_datetime(@filter_options)
					edt = task.end_datetime(@filter_options)
					
					if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
						totals[:begin_datetime] = bdt
					end
					if !totals[:end_datetime] || edt > totals[:end_datetime]
						totals[:end_datetime] = edt
					end
					
					puts "table task: #{totals[:task_c]} #{task} #{duration}"
					
					table << [
						totals[:task_c],
						task.begin_datetime_s(@filter_options),
						task.end_datetime_s(@filter_options),
						duration.to_human,
						tracks_c,
						'%s %s' % [task.short_id, task.name]
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
				raise NotImplementedError
			end
			
			def export_csv
				
			end
			
			def filtered_tasks
				# Get Tracks.
				tracks = @timr.tracks(@filter_options)
				
				puts "filtered_tasks tracks: #{tracks.count}"
				
				# Convert Tracks to Tasks. Convert the Array to a Set removes all duplicates.
				tracks.map{ |track_id, track| track.task }.to_set
			end
			
			def help
				puts 'usage: timr report '
				puts '   or: timr report [-h|--help]'
				puts
				puts 'Options'
				puts '    -d, --day   <YYYY-MM-DD>                  A single day from 00:00 to 23:59.'
				puts '    -m, --month <[YYYY-]MM>                   A single month from 01 to 31.'
				puts '    -y, --year  [<YYYY>]                      A single year from 01-01 to 12-31.'
				puts '    -a, --all                                 All.'
				puts
				puts 'Columns'
				puts '    START    Task Start Date'
				puts '    END      Task End Date'
				puts '    DUR      Task Duration'
				puts '    TrC      Tracks Count'
				puts '    TASK     Task ID and Name.'
				puts
			end
			
		end # class TrackCommand
	
	end # module Timr
end # module TheFox
