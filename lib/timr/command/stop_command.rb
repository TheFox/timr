
require 'pp' # @TODO remove pp

module TheFox
	module Timr
		module Command
			
			# Stop the current running [Track](rdoc-ref:TheFox::Timr::Model::Track).
			class StopCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				def initialize(argv = Array.new)
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					
					@start_date_opt = nil
					@start_time_opt = nil
					@end_date_opt = nil
					@end_time_opt = nil
					@message_opt = nil
					@append_opt = false
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						
						when '--sd', '--start-date'
							@start_date_opt = argv.shift
						when '--st', '--start-time'
							@start_time_opt = argv.shift
						
						when '--ed', '--end-date', '-d', '--date'
							@end_date_opt = argv.shift
						when '--et', '--end-time', '-t', '--time'
							@end_time_opt = argv.shift
						
						when '-m', '--message'
							@message_opt = argv.shift
						when '-a', '--append'
							@append_opt = true
						else
							raise StopCommandError, "Unknown argument '#{arg}'. See 'timr stop --help'."
						end
					end
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					options = {
						:start_date => @start_date_opt,
						:start_time => @start_time_opt,
						
						:end_date => @end_date_opt,
						:end_time => @end_time_opt,
						
						:message => @message_opt,
						:append => @append_opt,
					}
					
					@timr = Timr.new(@cwd)
					track = @timr.stop(options)
					unless track
						puts 'No running Track to stop.'
						return
					end
					
					puts track.to_detailed_str
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr stop [[--start-date <YYYY-MM-DD>] --start-time <HH:MM[:SS]>]'
					puts '                 [-d|--date <YYYY-MM-DD>] [-t|--time <HH:MM[:SS]>]'
					puts '                 [-m|--message <message>] [-a|--append]'
					puts '   or: timr stop [-h|--help]'
					puts
					puts 'Track Options'
					puts '    -m, --message              Track Message. What have you done? This will'
					puts '                               overwrite the start message. See --append option.'
					puts '    -a, --append               Append the message from --message option'
					puts '                               to the start message.'
					puts
					puts '    --sd, --start-date <YYYY-MM-DD>    Overwrite the start date.'
					puts '    --st, --start-time <HH:MM[:SS]>    Overwrite the start time.'
					puts
					puts '    --ed, --end-date <YYYY-MM-DD>      End Date. Default: today'
					puts '    --et, --end-time <HH:MM[:SS]>      End Time. Default: now'
					puts
					puts '    -d, --date <YYYY-MM-DD>            Alias for --end-date.'
					puts '    -t, --time <HH:MM[:SS]>            Alias for --end-time.'
					puts
				end
				
			end # class StopCommand
			
		end # module Command
	end # module Timr
end # module TheFox
