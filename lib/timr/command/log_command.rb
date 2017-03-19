
require 'date'
require 'time'

module TheFox
	module Timr
		
		class LogCommand < Command
			
			include Term::ANSIColor
			
			def initialize(argv = [])
				super()
				
				today = Date.today
				
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
						day = argv.shift
						@from_opt = Time.parse("#{day} 00:00:00")
						@to_opt   = Time.parse("#{day} 23:59:59")
					when '-m', '--month'
						parts = argv.shift.split('-').map{ |s| s.to_i }
						if parts.count == 1
							y = today.year
							m = parts.first
						else
							y, m = parts
						end
						if y < 2000 # shit
							y += 2000
						end
						
						start_date = Date.new(y, m, 1)
						end_date   = Date.new(y, m, -1)
						
						@from_opt = Time.parse("#{start_date.strftime('%F')} 00:00:00")
						@to_opt   = Time.parse("#{end_date.strftime('%F')} 23:59:59")
					when '-y', '--year'
						y = argv.shift
						if y
							y = y.to_i
						else
							y = today.year
						end
						if y < 2000 # shit
							y += 2000
						end
						
						start_date = Date.new(y, 1, 1)
						end_date   = Date.new(y, 12, -1)
						
						@from_opt = Time.parse("#{start_date.strftime('%F')} 00:00:00")
						@to_opt   = Time.parse("#{end_date.strftime('%F')} 23:59:59")
					
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
				
				
				unless @from_opt
					@from_opt = Time.new(today.year, today.month, today.day, 0, 0, 0)
				end
				unless @to_opt
					@to_opt = Time.new(today.year, today.month, today.day, 23, 59, 59)
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				print_small_table
			end
			
			private
			
			def print_small_table
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
				}
				
				table_has_rows = false
				track_c = 0
				get_tracks.each do |track_id, track|
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
							
							track_c += 1
							
							begin_datetime_s = track.begin_datetime_s('%y-%m-%d %H:%M', from)
							end_datetime_s = track.end_datetime_s('%H:%M %y-%m-%d', to)
							duration = track.duration({:from => from, :to => to})
							
							table << [
								track_c,
								begin_datetime_s,
								end_datetime_s,
								duration.to_human,
								task.short_id,
								'%s %s' % [track.short_id, track.title(15)],
							]
							
							totals[:duration] += duration
						end
					else
						track_c += 1
						
						begin_datetime_s = track.begin_datetime_s('%y-%m-%d %H:%M', @from_opt)
						end_datetime_s = track.end_datetime_s('%H:%M %y-%m-%d', @to_opt)
						duration = track.duration({:from => @from_opt, :to => @to_opt})
						
						table << [
							track_c,
							begin_datetime_s,
							end_datetime_s,
							duration.to_human,
							task.short_id,
							'%s %s' % [track.short_id, track.title(15)],
						]
						
						totals[:duration] += duration
					end
				end
				
				table << []
				
				# Add totals to the bottom.
				table << [
					nil,        # track_c
					nil,        # begin_datetime
					'TOTAL',    # end_datetime
					totals[:duration].to_human, # duration
					nil,        # task
					nil,        # track
				]
				
				if table_has_rows
					puts table
				else
					puts 'No tracks found.'
				end
			end
			
			def get_tracks
				# if @from_opt || @to_opt
				# 	from = @from_opt
				# 	to = @to_opt
				# else
				# 	today = Date.today
				# 	from = Time.new(today.year, today.month, today.day, 0, 0, 0)
				# 	to = Time.new(today.year, today.month, today.day, 23, 59, 59)
				# end
				
				@timr.tracks({:from => @from_opt, :to => @to_opt})
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
