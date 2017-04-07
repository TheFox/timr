
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
				
				private
				
				def help
					puts 'usage: timr [-V|--version] [-h|--help] [-C <path>] <command> [<args>]'
					puts
					puts '    -C <path>            Path to the project base directory.'
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
