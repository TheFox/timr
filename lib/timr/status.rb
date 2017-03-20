
require 'term/ansicolor'

module TheFox
	module Timr
		
		# Used as Task or Track Status.
		# 'R'  running
		# 'S'  stopped
		# 
		# 'P'  paused
		#      It's actually stopped but with an additional flag.
		#     
		# '-'  not started
		# 'U'  unknown
		class Status
			
			include Term::ANSIColor
			
			attr_reader :short_status
			attr_reader :long_status
			
			def initialize(short_status)
				@short_status = short_status
				
				@long_status = nil
				set_long_status
			end
			
			def colorized
				case @short_status
				when 'R'
					green(@long_status)
				when 'S'
					red(@long_status)
				else
					@long_status
				end
			end
			
			def to_s
				long_status
			end
			
			private
			
			def set_long_status
				@long_status = case @short_status
					when '-'
						'not started'
					when 'R'
						'running'
					when 'S'
						'stopped'
					when 'P'
						'paused'
					when 'U'
						'unknown'
					else
						'unknown'
					end
			end
			
		end # class Status
		
	end # module Timr
end # module TheFox
