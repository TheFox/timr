
module TheFox
	module TermKit
		module Exception
			
			class ParentClassNotInitializedException < StdException
				
				def initialize(msg = nil)
					msg << ' -- Forgot to call super() for parent initialization?'
					super
				end
				
			end
			
		end
	end
end
