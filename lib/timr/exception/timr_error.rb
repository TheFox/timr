
module TheFox
	module Timr
		
		# # Errors Inheritance Tree
		# 
		# TimrError is the basic class for all Timr Error classes. It subclasses from Rubys StandardError.
		# 
		# - TimrError
		# 	- ModelError
		# 		- IdError
		# 		- TaskError
		# 		- TrackError
		# 	- DateTimeError
		# 	- CommandError
		# 		- ContinueCommandError
		# 		- LogCommandError
		# 		- PauseCommandError
		# 		- PopCommandError
		# 		- PushCommandError
		# 		- ReportCommandError
		# 		- StartCommandError
		# 		- StatusCommandError
		# 		- StopCommandError
		# 		- TaskCommandError
		# 		- TrackCommandError
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
			
			class CommandError < TimrError
			end
			
			class ContinueCommandError < TimrError
			end
			
			class LogCommandError < TimrError
			end
			
			class PauseCommandError < TimrError
			end
			
			class PopCommandError < TimrError
			end
			
			class PushCommandError < TimrError
			end
			
			class ReportCommandError < TimrError
			end
			
			class StartCommandError < TimrError
			end
			
			class StatusCommandError < TimrError
			end
			
			class StopCommandError < TimrError
			end
			
			class TaskCommandError < TimrError
			end
			
			class TrackCommandError < TimrError
			end
			
		end # module Error
		
	end # module Timr
end # module TheFox
