
module TheFox
	module Timr
		
		# # Inheritance Tree of Error classes
		# 
		# TimrError is the basic class for all Timr Error classes. It subclasses from Rubys StandardError.
		# 
		# - TimrError
		# 	- ModelError
		# 		- IdError
		# 		- TaskError
		# 		- TrackError
		# 	- DateTimeError
		module Error
		
			class TimrError < StandardError
			end
			
			class ModelError < TimrError
			end
			
			class IdError < ModelError
			end
			
			class TaskError < ModelError
			end
			
			class TrackError < ModelError
			end
			
			class DateTimeError < TimrError
			end
			
		end # module Error
		
	end # module Timr
end # module TheFox
