
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
		# 		- StackError
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
		# 		- HelpCommandError
		# 	- DurationError
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
			
			class StackError < ModelError
			end
			
			class DateTimeError < TimrError
			end
			
			class CommandError < TimrError
			end
			
			class ContinueCommandError < CommandError
			end
			
			class LogCommandError < CommandError
			end
			
			class PauseCommandError < CommandError
			end
			
			class PopCommandError < CommandError
			end
			
			class PushCommandError < CommandError
			end
			
			class ReportCommandError < CommandError
			end
			
			class StartCommandError < CommandError
			end
			
			class StatusCommandError < CommandError
			end
			
			class StopCommandError < CommandError
			end
			
			class TaskCommandError < CommandError
			end
			
			class TrackCommandError < CommandError
			end
			
			class HelpCommandError < CommandError
			end
			
			class DurationError < TimrError
			end
			
		end # module Error
		
	end # module Timr
end # module TheFox
