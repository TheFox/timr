
module TheFox
	module Timr
		
		class HelpCommand < Command
			
			def run
				puts 'usage: timr [-V|--version] [-h|--help] [-C <path>] <command> [<args>]'
				puts
				puts '    -C <path>            Path to the project base directory.'
				puts '                         Default: ~/.timr/project'
				puts
				puts 'Commands'
				puts '    status               Show the current Stack.'
				puts '    log                  Show Tracks.'
				puts
				puts '    start                Start or continue working on a Task.'
				puts '    stop                 Stop the current running Track.'
				puts
				puts '    continue             Continue the Top Track of the Stack.'
				puts '    pause                Pause the Top Track of the Stack.'
				puts
				puts '    push                 Push a new Track on the Stack and pause the old one.'
				puts '    pop                  Pop the Top Track and continue the old one.'
				puts
				puts "    task                 Task related commands. See 'timr task --help'."
				puts "    track                Track related commands. See 'timr track --help'."
				puts
				puts "See 'timr <command> -h' to read details about a specific command."
			end
			
		end # class HelpCommand
	
	end # module Timr
end # module TheFox
