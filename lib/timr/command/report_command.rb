
module TheFox
	module Timr
		
		class ReportCommand < Command
			
			def initialize(argv = [])
				@help_opt = false
				
				
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				
			end
			
			private
			
			def help
				puts 'usage: timr report [-h|--help]'
			end
			
		end # class ReportCommand
	
	end # module Timr
end # module TheFox
