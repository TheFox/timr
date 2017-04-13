
module TheFox
	module Timr
		module Command
			
			# Continue the previous paused [Track](rdoc-ref:TheFox::Timr::Model::Track).
			# 
			# Man page: [timr-continue(1)](../../../../man/timr-continue.1.html)
			class ContinueCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/timr-continue.1'
				
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
							raise ContinueCommandError, "Unknown argument '#{arg}'. See 'timr continue --help'."
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
					
					options = {
						:date => @date_opt,
						:time => @time_opt,
					}
					
					track = @timr.continue(options)
					unless track
						puts 'No running Track to continue.'
						return
					end
					
					puts '--- CONTINUED ---'
					puts track.to_compact_str
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr continue [-d|--date <date>] [-t|--time <time>]'
					puts '   or: timr continue [-h|--help]'
					puts
					puts 'Track Options'
					puts '    -d, --date <date>    Track Start Date'
					puts '    -t, --time <time>    Track Start Time'
					puts
					HelpCommand.print_datetime_help
					puts
				end
				
			end # class ContinueCommand
			
		end # module Command
	end # module Timr
end # module TheFox
