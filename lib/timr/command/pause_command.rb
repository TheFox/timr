
module TheFox
	module Timr
		
		class PauseCommand < Command
			
			def initialize(argv = Array.new)
				super()
				
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
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr pause --help'."
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
				
				track = @timr.pause(options)
				unless track
					puts 'No running Track to pause.'
					exit
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				duration = track.duration.to_human
				status = track.status.colorized
				stack = TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')
				
				puts '--- PAUSED ---'
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  End:   %s' % [track.end_datetime_s]
				puts '  Duration: %16s' % [duration]
				puts '  Status: %s' % [status]
				puts 'Stack: %s' % [stack]
			end
			
			private
			
			def help
				puts 'usage: timr pause [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
				puts '   or: timr pause [-h|--help]'
				puts
				puts 'Track Options'
				puts '    -d, --date <YYYY-MM-DD>    End Date'
				puts '    -t, --time <HH:MM[:SS]>    End Time'
				puts
			end
			
		end # class PauseCommand
	
	end # module Timr
end # module TheFox
