
module TheFox
	module TermKit
		module Exception
			
			class UnhandledEventException < StdException
				
				def initialize(event)
					@event = event
				end
				
				def event
					@event
				end
				
			end
		
		end
	end
end
