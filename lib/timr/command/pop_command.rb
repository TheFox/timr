
module TheFox
	module Timr
		module Command
			
			# This command pops the Top [Track](rdoc-ref:TheFox::Timr::Model::Track),
			# makes a duplication of the next Track on the [Stack](rdoc-ref:TheFox::Timr::Model::Stack), pops the next,
			# and pushes the duplication Track back on the Stack. There are
			# at least 3 Tracks involved.
			# 
			# ### Example
			# 
			# Example Stack before pop:
			# 
			# ```
			# Track 1234 stopped
			# Track 2345 stopped
			# Track 3456 running
			# ```
			# 
			# Pop Execution
			# 
			# 1. Make duplication of Track `3456` -> new Track `4567`.  
			#   Because Track `3456` is the latest Track on the Stack. Sometimes call *Top Track*.
			# 2. Pop Track `3456` from Stack.
			# 3. Push new Track `4567` to Stack.
			# 
			# Example Stack after pop:
			# 
			# ```
			# Track 1234 stopped
			# Track 2345 stopped
			# Track 4567 running
			# ```
			class PopCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/pop.1'
				
				def initialize(argv = Array.new)
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					
					@date_opt = nil
					@time_opt = nil
					@start_date_opt = nil # @TODO --start-date
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
							raise PopCommandError, "Unknown argument '#{arg}'. See 'timr pop --help'."
						end
					end
				end
				
				# See BasicCommand#run.
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
						return
					end
					
					task = track.task
					unless task
						raise TrackError, "Track #{track.id} has no Task."
					end
					
					puts '--- POPED ---'
					puts track.to_detailed_str
					puts
					
					# Continue
					options = {
						:date => @date_opt,
						:time => @time_opt,
					}
					
					track = @timr.continue(options)
					unless track
						puts 'No running Track left on Stack to continue.'
						return
					end
					
					task = track.task
					unless task
						raise TrackError, "Track #{track.id} has no Task."
					end
					
					puts '--- CONTINUED ---'
					puts track.to_detailed_str
					puts
					puts @timr.stack
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
			
		end # module Command
	end # module Timr
end # module TheFox
