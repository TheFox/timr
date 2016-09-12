
module TheFox
	module TermKit
		module Exception
			
			class UnhandledEventException < StdException
				
				attr_reader :event
				
				def initialize(event)
					@event = event
				end
				
			end
		
		end
	end
end
