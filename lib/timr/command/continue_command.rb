
module TheFox
	module Timr
		
		class ContinueCommand < Command
			
			def initialize(argv = Array.new)
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				
				@date_opt = nil
				@time_opt = nil
				
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
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr continue --help'."
					end
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				options = {
					:date => @date_opt,
					:time => @time_opt,
				}
				
				track = @timr.continue(options)
				unless track
					puts 'No running Track to continue.'
					exit
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				duration = track.duration.to_human
				status = track.status.colorized
				
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  End:   %s' % [track.end_datetime_s]
				puts '  Duration: %16s' % [duration]
				puts '  Status: %s (continued)' % [status]
				puts 'Stack: %s' % [TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')]
			end
			
			private
			
			def help
				puts 'usage: timr continue [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
				puts '   or: timr continue [-h|--help]'
				puts
				puts 'Track Options'
				puts '    -d, --date <YYYY-MM-DD>    New Start Date'
				puts '    -t, --time <HH:MM[:SS]>    New Start Time'
				puts
			end
			
		end # class ContinueCommand
	
	end # module Timr
end # module TheFox