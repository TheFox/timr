
require 'set'

module TheFox
	module Timr
		module Command
			
			# Remove current running Track. Paused commands will not be deleted.
			# 
			# Man page: [timr-reset(1)](../../../../man/timr-reset.1.html)
			class ResetCommand < BasicCommand
				
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/timr-reset.1'
				
				def initialize(argv = Array.new)
					super()
					
					@help_opt = false
					@stack_opt = false
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						when '-s', '--stack'
							@stack_opt = true
						else
							raise ResetCommandError, "Unknown argument '#{arg}'. See 'timr reset --help'."
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
					
					track = @timr.stack.current_track
					if track && track.running?
						puts '--- RESET ---'
						puts track.to_compact_str
						puts
					end
					
					@timr.reset({:stack => @stack_opt})
					
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr reset [-s|--stack]'
					puts
					puts 'Options'
					puts '    -s, --stack    Clean the Stack.'
					puts
				end
				
			end # class TrackCommand
			
		end # module Command
	end # module Timr
end # module TheFox
