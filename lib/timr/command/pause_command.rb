
module TheFox
	module Timr
		module Command
			
			# Pause the current running [Track](rdoc-ref:TheFox::Timr::Model::Track).
			class PauseCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/pause.1'
				
				def initialize(argv = Array.new)
					super()
					
					@help_opt = false
					
					@end_date_opt = nil
					@end_time_opt = nil
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						when '--ed', '--end-date', '-d', '--date'
							@end_date_opt = argv.shift
						when '--et', '--end-time', '-t', '--time'
							@end_time_opt = argv.shift
						else
							raise PauseCommandError, "Unknown argument '#{arg}'. See 'timr pause --help'."
						end
					end
				end
				
				# See BasicCommand.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					options = {
						:end_date => @end_date_opt,
						:end_time => @end_time_opt,
					}
					
					track = @timr.pause(options)
					unless track
						puts 'No running Track to pause.'
						return
					end
					
					puts '--- PAUSED ---'
					puts track.to_detailed_str
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr pause [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
					puts '   or: timr pause [-h|--help]'
					puts
					puts 'Track Options'
					puts '    --ed, --end-date <YYYY-MM-DD>    End Date'
					puts '    --et, --end-time <HH:MM[:SS]>    End Time'
					puts
					puts '    -d, --date <YYYY-MM-DD>          Alias for --end-date.'
					puts '    -t, --time <HH:MM[:SS]>          Alias for --end-time.'
					puts
				end
				
			end # class PauseCommand
			
		end # module Command
	end # module Timr
end # module TheFox
