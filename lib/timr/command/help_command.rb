
module TheFox
	module Timr
		
		class HelpCommand < Command
			
			def run
				puts 'usage: timr [-V|--version] [-h|--help] [-C <path>] <command> [<args>]'
				puts
				puts '    -C <path>    Path to the project base directory. Default: ~/.timr/project'
				puts
				puts 'Commands'
				puts '    status, s            Show the current Stack.'
				puts
				puts '    start                Start or continue working on a Task.'
				puts '                         Creates a new Track.'
				puts '    stop                 Stop the current running Track.'
				puts
				puts '    continue, cont, c    Continue the Top Track on the Stack.'
				puts
				puts '    push                 Push a new Track on the Stack and pause the old one.'
				puts '    pop                  Pop the Top Track and continue the old one.'
				
				# puts "    task     Task related commands. See 'timr task --help'."
				# puts "    track    Track related commands. See 'timr track --help'."
				
				puts
			end
			
		end # class HelpCommand
	
	end # module Timr
end # module TheFox
