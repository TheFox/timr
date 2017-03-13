
require 'pp'

module TheFox
	module Timr
		
		class StopCommand < Command
			
			def initialize(argv = [])
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				
				@start_date_opt = nil
				@start_time_opt = nil
				@date_opt = nil
				@time_opt = nil
				@message_opt = nil
				@append_opt = false
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '--start-date'
						@start_date_opt = argv.shift
					when '--start-time'
						@start_time_opt = argv.shift
					when '-d', '--date'
						@date_opt = argv.shift
					when '-t', '--time'
						@time_opt = argv.shift
					when '-m', '--message'
						@message_opt = argv.shift
					when '-a', '--append'
						@append_opt = true
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr stop --help'."
					end
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				options = {
					:start_date => @start_date_opt,
					:start_time => @start_time_opt,
					
					:date => @date_opt,
					:time => @time_opt,
					
					:message => @message_opt,
					:append => @append_opt,
				}
				
				@timr = Timr.new(@cwd)
				track = @timr.stop(options)
				unless track
					puts "No running Track to stop."
					exit
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task"
				end
				
				puts '----------'
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  End:   %s' % [track.end_datetime_s]
				puts '  Duration: %16s' % [track.duration_s]
				puts '  Status: %s' % [track.long_status]
			end
			
			private
			
			def help
				puts 'usage: timr stop [[--start-date <YYYY-MM-DD>] --start-time <HH:MM[:SS]>]'
				puts '       [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
				puts '       [-m|--message <message>] [-a|--append]'
				puts '   or: timr stop [-h|--help]'
				puts
				puts 'Track Options'
				puts '    -m, --message              Track Message. What have you done? This will overwrite'
				puts '                               the start message. See --append option.'
				puts '    -a, --append               Append the message from --message option to the start message.'
				puts '    --start-date <YYYY-MM-DD>  Overwrite the start date.'
				puts '    --start-time <HH:MM[:SS]>  Overwrite the start time.'
				puts '    -d, --date <YYYY-MM-DD>        End Date. Default: today'
				puts '    -t, --time <HH:MM[:SS]>    End Time.'
				puts
			end
			
		end # class StopCommand
	
	end # module Timr
end # module TheFox
