
# require 'pp'
require 'date'
require 'time'

module TheFox
	module Timr
		
		class DateTimeHelper
			
			# All methods in this block are static.
			class << self
				
				def convert_date(date)
					case date
					when String
						Time.parse(date).utc.to_date
					# when DateTime
					# 	date.to_time.utc.to_date
					# when Time
					# 	date.utc.to_date
					when nil
						Time.now.utc.to_date
					end
				end
				
				def convert_time(time)
					case time
					when String
						Time.parse(time).utc
					# when DateTime
					# 	time.to_time.utc
					# when Date
					# 	Time.now.utc
					when nil
						Time.now.utc
					end
				end
				
				def seconds_to_hours(seconds)
					hours = seconds / 3600
					
					seconds -= hours * 3600
					minutes = seconds / 60
					
					seconds -= minutes * 60
					
					[hours, minutes, seconds]
				end
				
			end
			
		end # class DateTimeHelper
		
	end # module Timr
end # module TheFox
