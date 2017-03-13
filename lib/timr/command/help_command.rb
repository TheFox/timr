
module TheFox
	module Timr
		
		class HelpCommand < Command
			
			def run
				puts 'usage: timr [-V|--version] [-h|--help] [-C <path>] <command> [<args>]'
				puts
				puts '    -C <path>    Path to the project base directory. Default: ~/.timr/project'
				puts
				puts 'Commands'
				puts '    start    Start or continue working on a Task. Creates a new Track.'
				puts '    stop     Stop the current running Track.'
				
				# puts "    task     Task related commands. See 'timr task --help'."
				# puts "    track    Track related commands. See 'timr track --help'."
				
				puts
			end
			
		end # class HelpCommand
	
	end # module Timr
end # module TheFox
