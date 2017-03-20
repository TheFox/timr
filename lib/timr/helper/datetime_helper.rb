
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
				
				def parse_day_argv(argv)
					day = argv.shift
					from = Time.parse("#{day} 00:00:00")
					to   = Time.parse("#{day} 23:59:59")
					[from, to]
				end
				
				def parse_month_argv(argv)
					parts = argv.shift.split('-').map{ |s| s.to_i }
					if parts.count == 1
						y = Date.today.year
						m = parts.first
					else
						y, m = parts
					end
					if y < 2000 # shit
						y += 2000
					end
					
					start_date = Date.new(y, m, 1)
					end_date   = Date.new(y, m, -1)
					
					from = Time.parse("#{start_date.strftime('%F')} 00:00:00")
					to   = Time.parse("#{end_date.strftime('%F')} 23:59:59")
					[from, to]
				end
				
				def parse_year_argv(argv)
					y = argv.shift
					if y
						y = y.to_i
					else
						y = Date.today.year
					end
					if y < 2000 # shit
						y += 2000
					end
					
					start_date = Date.new(y, 1, 1)
					end_date   = Date.new(y, 12, -1)
					
					from = Time.parse("#{start_date.strftime('%F')} 00:00:00")
					to   = Time.parse("#{end_date.strftime('%F')} 23:59:59")
					[from, to]
				end
				
			end
			
		end # class DateTimeHelper
		
	end # module Timr
end # module TheFox
