
module TheFox
	module Timr
		module Command
			
			# Pause the current running [Track](rdoc-ref:TheFox::Timr::Model::Track).
			class PauseCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
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
						:date => @date_opt,
						:time => @time_opt,
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
					puts '    -d, --date <YYYY-MM-DD>    End Date'
					puts '    -t, --time <HH:MM[:SS]>    End Time'
					puts
				end
				
			end # class PauseCommand
			
		end # module Command
	end # module Timr
end # module TheFox
