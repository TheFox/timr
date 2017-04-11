
module TheFox
	module Timr
		module Command
			
			# Print the overview help page.
			class HelpCommand < BasicCommand
				
				def initialize(argv = Array.new)
					# puts "help #{argv}"
					
					super()
					
					@command_opt = nil
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						#arg = argv.shift
						
						unless @command_opt
							@command_opt = argv.shift
						end
					end
				end
				
				# See BasicCommand#run.
				def run
					if @command_opt
						command_class = BasicCommand.get_command_class_by_name(@command_opt)
						# command = command_class.new
						# puts "CLASS: #{command_class}"
						
						if defined?(command_class::MAN_PATH)
							system("man #{command_class::MAN_PATH}")
						else
							raise HelpCommandError, "No manual page found for '#{@command_opt}'. See 'timr --help'."
						end
					else
						help
					end
				end
				
				# All methods in this block are static.
				class << self
					
					def print_id_help
						print_task_id_help
						puts
						print_track_id_help
					end
					
					def print_task_id_help
						puts '    <task_id>     Task ID (SHA1 hex)'
						puts '                  If not specified a new Task will be created.'
					end
					
					def print_track_id_help
						puts '    <track_id>    Track ID (SHA1 hex)'
						puts '                  If specified a new Track with the same'
						puts '                  message will be created.'
					end
					
					def print_datetime_help
						puts 'DateTime Formats'
						puts "    <date_time>    A DateTime is one single string"
						puts "                   representing '<date> <time>'."
						puts '    <date>         Formats: YYYYMMDD, YYYY-MM-DD, MM/DD/YYYY, DD.MM.YYYY'
						puts '    <time>         Formats: HH:MM, HH:MM:SS'
					end
					
					def print_estimation_help(ext = false)
						puts 'Duration'
						puts '    Duration is parsed by chronic_duration.'
						puts '    Examples:'
						puts "        -e 2:10:5         # Sets Estimation to 2h 10m 5s."
						puts "        -e '2h 10m 5s'    # Sets Estimation to 2h 10m 5s."
						puts
						if ext
							puts "    Use '+' or '-' to calculate with Estimation Times:"
							puts "        -e '-45m'         # Subtracts 45 minutes from the original Estimation."
							puts "        -e '+1h 30m'      # Adds 1 hour 30 minutes to the original Estimation."
							puts
						end
						puts '    See chronic_duration for more examples.'
						puts '    https://github.com/henrypoydar/chronic_duration'
					end
					
					def print_man_units_help
						puts 'Man Units'
						puts '    8 hours are 1 man-day.'
						puts '    5 man-days are 1 man-week, and so on.'
					end
					
				end
				
				private
				
				def help
					puts 'usage: timr [-V|--version] [-h|--help] [-C <path>] <command> [<args>]'
					puts
					puts '    -V, --version        Show version.'
					puts '    -h, --help           Show help.'
					puts '    -C <path>            Set path to the project base directory.'
					puts '                         Default: ~/.timr/defaultc'
					puts
					puts 'Commands'
					puts '    start                Start working on a Task.'
					puts '    stop                 Stop the current running Task/Track.'
					puts
					puts '    pause                Pause the Top Track of the Stack.'
					puts '    continue             Continue the Top Track of the Stack.'
					puts
					puts '    push                 Push a new Track on the Stack and pause the old one.'
					puts '    pop                  Pop the Top Track and continue the old one.'
					puts
					puts '    status               Show the current Stack.'
					puts '    log                  Show recent Tracks.'
					puts
					puts "    task                 Task related commands. See 'timr task --help'."
					puts "    track                Track related commands. See 'timr track --help'."
					puts
					puts '    report               Generate a report.'
					puts
					puts "See 'timr <command> --help' to read details about a specific command,"
					puts " or 'timr help <command>' to open the man page for this command."
					puts "Also see 'man' directory for available man pages."
				end
				
			end # class HelpCommand
			
		end # module Command
	end # module Timr
end # module TheFox
