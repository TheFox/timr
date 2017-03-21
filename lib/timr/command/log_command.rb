
require 'date'
require 'time'

module TheFox
	module Timr
		
		class LogCommand < Command
			
			def initialize(argv = Array.new)
				super()
				puts "#{Time.now.to_ms} #{self.class} #{__method__}"
				
				@help_opt = false
				
				@from_opt = nil
				@to_opt = nil
				
				@start_date = nil
				@end_date = nil
				
				@start_time = nil
				@end_time = nil
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					
					when '-s', '--from'
						@from_opt = Time.parse(argv.shift)
					when '-e', '--to'
						@to_opt = Time.parse(argv.shift)
					
					when '-d', '--day'
						@from_opt, @to_opt = DateTimeHelper.parse_day_argv(argv)
					when '-m', '--month'
						@from_opt, @to_opt = DateTimeHelper.parse_month_argv(argv)
					when '-y', '--year'
						@from_opt, @to_opt = DateTimeHelper.parse_year_argv(argv)
					
					when '-a', '--all'
						@from_opt = Time.parse('1970-01-01 00:00:00')
						@to_opt   = Time.parse('2099-12-31 23:59:59')
					
					when '--sd', '--start-date'
						@start_date = Time.parse(argv.shift)
					when '--ed', '--end-date'
						@end_date = Time.parse(argv.shift)
					when '--st', '--start-time'
						@start_time = Time.parse(argv.shift)
					when '--et', '--end-time'
						@end_time = Time.parse(argv.shift)
					
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr log --help'."
					end
				end
				
				@daytime_filter = false
				if @start_date && @end_date && @start_time && @end_time
					@from_opt = Time.parse("#{@start_date.strftime('%F')} #{@start_time.strftime('%T')}")
					@to_opt   = Time.parse("#{@end_date.strftime('%F')} #{@end_time.strftime('%T')}")
					
					# puts "from parsed: #{@from_opt.strftime('%F %T')}"
					# puts "to   parsed: #{@to_opt.strftime('%F %T')}"
					@daytime_filter = true
				end
				
				today = Date.today
				unless @from_opt
					@from_opt = Time.new(today.year, today.month, today.day, 0, 0, 0)
				end
				unless @to_opt
					@to_opt = Time.new(today.year, today.month, today.day, 23, 59, 59)
				end
				
				@filter_options = {:from => @from_opt, :to => @to_opt}
				
				
				puts "#{Time.now.to_ms} #{self.class} #{__method__} END"
			end
			
			def run
				puts "#{Time.now.to_ms} #{self.class} #{__method__}"
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				print_small_table
			end
			
			private
			
			def print_small_table
				puts "#{Time.now.to_ms} #{self.class} #{__method__}"
				
				puts 'Selected datetime range:'
				if @daytime_filter
					puts "On every day from #{@start_date.strftime('%F')}"
					puts "               to #{@end_date.strftime('%F')}"
					puts "          between #{@start_time.strftime('%T %z')}"
					puts "              and #{@end_time.strftime('%T %z')}"
				else
					puts " From #{@from_opt.strftime('%F %T %z')}"
					puts "   To #{@to_opt.strftime('%F %T %z')}"
				end
				puts
				
				table_options = {
					:headings => [
						{:format => '%3s', :label => '###'},
						{:format => '%-14s', :label => 'START', :padding_left => ' ', :padding_right => ' '},
						{:format => '%-14s', :label => 'END', :padding_left => ' ', :padding_right => ' '},
						{:format => '%7s', :label => 'DUR', :padding_left => ' ', :padding_right => ' '},
						{:format => '%-6s', :label => 'TASK', :padding_right => ' '},
						{:format => '%s', :label => 'TRACK'},
					],
				}
				table = Table.new(table_options)
				
				totals = {
					:duration => Duration.new,
					:task_c => 0,
					
					:begin_datetime => nil,
					:end_datetime   => nil,
				}
				
				tmp_begin_options = {:format => '%y-%m-%d %H:%M'}
				tmp_end_options = {:format => '%H:%M %y-%m-%d'}
				
				glob_begin_options = {
					:format => tmp_begin_options[:format],
					:from => @from_opt,
				}
				glob_end_options = {
					:format => tmp_end_options[:format],
					:to => @to_opt,
				}
				
				table_has_rows = false
				@timr.tracks(@filter_options).each do |track_id, track|
					table_has_rows = true
					
					task = track.task
					
					if @daytime_filter
						track.days.each do |track_day|
							from = Time.parse("#{track_day.strftime('%F')} #{@start_time.strftime('%T')}")
							to   = Time.parse("#{track_day.strftime('%F')} #{@end_time.strftime('%T')}")
							
							# Skip out-of-scope Tracks.
							if track.end_datetime < from || track.begin_datetime > to
								next
							end
							
							totals[:task_c] += 1
							
							bdt = track.begin_datetime(@filter_options)
							edt = track.end_datetime(@filter_options)
							if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
								totals[:begin_datetime] = bdt
							end
							if !totals[:end_datetime] || edt > totals[:end_datetime]
								totals[:end_datetime] = edt
							end
							
							tmp_begin_options[:from] = from
							tmp_end_options[:to] = to
							begin_datetime_s = track.begin_datetime_s(tmp_begin_options)
							end_datetime_s   = track.end_datetime_s(tmp_end_options)
							
							duration = track.duration({:from => from, :to => to})
							totals[:duration] += duration
							
							table << [
								track_c,
								begin_datetime_s,
								end_datetime_s,
								duration.to_human,
								task.short_id,
								'%s %s' % [track.short_id, track.title(15)],
							]
						end
					else
						totals[:task_c] += 1
						
						bdt = track.begin_datetime(@filter_options)
						edt = track.end_datetime(@filter_options)
						
						if !totals[:begin_datetime] || bdt < totals[:begin_datetime]
							totals[:begin_datetime] = bdt
						end
						if !totals[:end_datetime] || edt > totals[:end_datetime]
							totals[:end_datetime] = edt
						end
						
						pp glob_begin_options
						pp glob_end_options
						puts
						
						begin_datetime_s = track.begin_datetime_s(glob_begin_options)
						end_datetime_s   = track.end_datetime_s(glob_end_options)
						
						duration = track.duration(@filter_options)
						totals[:duration] += duration
						
						table << [
							totals[:task_c],
							begin_datetime_s,
							end_datetime_s,
							duration.to_human,
							task.short_id,
							'%s %s' % [track.short_id, track.title(15)],
						]
					end
				end
				
				table << []
				
				# Add totals to the bottom.
				table << [
					nil,        # track_c
					totals[:begin_datetime].strftime(glob_begin_options[:format]),
					totals[:end_datetime].strftime(glob_end_options[:format]),
					totals[:duration].to_human, # duration
					'TOTAL',    # task
					nil,        # track
				]
				
				if table_has_rows
					puts table
				else
					puts 'No tracks found.'
				end
				
				puts "#{Time.now.to_ms} #{self.class} #{__method__} END"
			end
			
			def help
				puts 'usage: timr log [-s|--from <date_time>] [-e|--to <date_time>]'
				puts '   or: timr log --sd <date> --ed <date> --st <time> --et <time>'
				puts '   or: timr log -d|--day <YYYY-MM-DD>'
				puts '   or: timr log -m|--month <YYYY-MM>'
				puts '   or: timr log -y|--year <YYYY>'
				puts '   or: timr log [-h|--help]'
				puts
				puts 'Total Filter'
				puts "    -s, --from '<YYYY-MM-DD> <HH:MM[:SS]>'    From Date/Time. Must be in"
				puts '                                              quotes. Default: today 00:00:00'
				puts "    -e, --to   '<YYYY-MM-DD> <HH:MM[:SS]>'    To Date/Time. Must be in quotes."
				puts '                                              Default: today 23:59:59'
				puts '    -d, --day   <YYYY-MM-DD>                  A single day from 00:00 to 23:59.'
				puts '    -m, --month <[YYYY-]MM>                   A single month from 01 to 31.'
				puts '    -y, --year  [<YYYY>]                      A single year from 01-01 to 12-31.'
				puts '    -a, --all                                 All.'
				puts
				puts 'Day Time Filter'
				puts '    --sd, --start-date <YYYY-MM-DD>    Start Date'
				puts '    --ed,   --end-date <YYYY-MM-DD>      End Date'
				puts '    --st, --start-time <HH:MM[:SS]>    Start Time'
				puts '    --et,   --end-time <HH:MM[:SS]>      End Time'
				puts
				puts 'If you would like to filter everything between 09:00 and 17:00 on every day'
				puts 'in the range from Mon 2017-03-06 to Fri 2017-03-10:'
				puts
				puts '  timr log --sd 2017-03-06 --ed 2017-03-10 --st 09:00 --et 17:00'
				puts
				puts 'Columns'
				puts '    START    Track Start Date'
				puts '    END      Track End Date'
				puts '    DUR      Track Duration'
				puts '    TASK     Task ID'
				puts '    TRACK    Track ID and Title.'
				puts
			end
			
		end # class LogCommand
	
	end # module Timr
end # module TheFox
