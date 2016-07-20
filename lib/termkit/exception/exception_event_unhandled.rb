
module TheFox
	module TermKit
		
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
