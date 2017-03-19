
require 'term/ansicolor'

module TheFox
	module Timr
		
		# This command pops the Top Track,
		# makes a duplication next Track on the Stack, also pops this
		# and pushes the duplication Track back on the Stack. There are
		# at least 3 Tracks involved.
		class PopCommand < Command
			
			include Term::ANSIColor
			
			def initialize(argv = [])
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				
				@date_opt = nil
				@time_opt = nil
				@start_date_opt = nil # @TODO
				@start_time_opt = nil
				@end_date_opt = nil
				@end_time_opt = nil
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-d', '--date'
						@date_opt = argv.shift
					when '-t', '--time'
						@time_opt = argv.shift
					# when '--sd', '--start-date'
					# 	@start_date_opt = argv.shift
					# when '--st', '--start-time'
					# 	@start_time_opt = argv.shift
					# when '--ed', '--end-date'
					# 	@end_date_opt = argv.shift
					# when '--et', '--end-time'
					# 	@end_time_opt = argv.shift
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr pop --help'."
					end
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				# Stop
				options = {
					:date => @date_opt,
					:time => @time_opt,
				}
				
				track = @timr.stop(options)
				unless track
					puts 'No running Track to pop/stop.'
					exit
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				duration = track.duration.to_human
				status = red(track.long_status)
				
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  End:   %s' % [track.end_datetime_s]
				puts '  Duration: %16s' % [duration]
				puts '  Status: %s (popped)' % [status]
				puts
				
				# Continue
				options = {
					:date => @date_opt,
					:time => @time_opt,
				}
				
				track = @timr.continue(options)
				unless track
					puts 'No running Track left on Stack to continue.'
					exit
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				duration = track.duration.to_human
				status = green(track.long_status)
				
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  End:   %s' % [track.end_datetime_s]
				puts '  Duration: %16s' % [duration]
				puts '  Status: %s (continued)' % [status]
				puts
				
				puts 'Stack: %s' % [TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')]
			end
			
			private
			
			def help
				puts 'usage: timr pop [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
				puts '   or: timr pop [-h|--help]'
				puts
				puts 'Track Options'
				puts '    -d, --date <YYYY-MM-DD>    End Date for the current running Track,'
				puts '                               Start Date for the next underlying Track'
				puts '                               to continue. Same for --time.'
				puts '    -t, --time <HH:MM[:SS]>    See --date.'
				puts
			end
			
		end # class PopCommand
	
	end # module Timr
end # module TheFox
