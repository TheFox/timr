
module TheFox
	module Timr
		
		# # Errors Inheritance Tree
		# 
		# TimrError is the basic class for all Timr Error classes. It subclasses from [Rubys StandardError](http://ruby-doc.org/core-2.4.1/Exception.html).
		# 
		# - TimrError
		# 	- ModelError
		# 		- IdError
		# 		- TaskError
		# 		- TrackError
		# 		- StackError
		# 	- DateTimeHelperError
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
		# 	- ThisShouldNeverHappenError
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
			
			# Use by TheFox::Timr::Helper::DateTimeHelper.
			class DateTimeHelperError < TimrError
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
			
			# This should really never happen. But you never know. ;)
			class ThisShouldNeverHappenError < TimrError
			end
			
		end # module Error
		
	end # module Timr
end # module TheFox
