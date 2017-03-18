
require 'term/ansicolor'
require 'time'

module TheFox
	module Timr
		
		class LogCommand < Command
			
			include Term::ANSIColor
			
			def initialize(argv = [])
				super()
				
				@help_opt = false
				
				@from_opt = nil
				@to_opt = nil
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-s', '--from'
						@from_opt = Time.parse(argv.shift)
						puts "from parsed: #{@from_opt.strftime('%Y-%m-%d %H:%M:%S')}"
					when '-e', '--to'
						@to_opt = Time.parse(argv.shift)
						puts "from parsed: #{@to_opt.strftime('%Y-%m-%d %H:%M:%S')}"
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr log --help'."
					end
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
				table_has_rows = false
				
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
					
				}
				
				track_c = 0
				get_tracks.each do |track|
					track_c += 1
					table_has_rows = true
					
					task = track.task
					
					#status = track.short_status
					
					if track.begin_datetime
						begin_datetime_s = track.begin_datetime_s('%y-%m-%d %H:%M')
					end
					
					if track.end_datetime
						end_datetime_s = track.end_datetime_s('%H:%M %y-%m-%d')
					end
					
					table << [
						track_c,
						begin_datetime_s,
						end_datetime_s,
						track.duration_s,
						task.short_id,
						'%s %s' % [track.short_id, track.title(15)],
					]
				end
				
				# Add totals to the bottom.
				# table << [
				# 	nil, # track_c
				# 	nil, # status
					
				# ]
				
				if table_has_rows
					puts table
				end
			end
			
			def get_tracks
				today = Date.today
				
				if @from_opt
					from = Time.parse(@from_opt)
				else
					from = Time.new(today.year, today.month, today.day, 0, 0, 0)
				end
				
				if @to_opt
					to = Time.parse(@to_opt)
				else
					to = Time.new(today.year, today.month, today.day, 23, 59, 59)
				end
				
				options = {
					:from => from,
					:to => to,
				}
				@timr.tracks(options)
			end
			
			def help
				puts 'usage: timr log [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
				puts '   or: timr log [-h|--help]'
				puts
				puts 'Track Options'
				puts '    -s, --from \'<YYYY-MM-DD> <HH:MM[:SS]>\'    From Date/Time. Must be one string.'
				puts '    -e, --to   \'<YYYY-MM-DD> <HH:MM[:SS]>\'    To Date/Time. Must be one string.'
				puts
			end
			
		end # class StopCommand
	
	end # module Timr
end # module TheFox
