
require 'time'
require 'thefox-ext'

module TheFox
	module Timr
		
		class Track
			
			def initialize(task, begin_time = Time.now, end_time = nil)
				@task = task
				@begin_time = begin_time
				@end_time = end_time
			end
			
			def begin_time=(begin_time)
				@begin_time = begin_time
			end
			
			def begin_time
				@begin_time
			end
			
			def end_time=(end_time)
				@end_time = end_time
			end
			
			def end_time
				@end_time
			end
			
			def diff
				if !@begin_time.nil? && !@end_time.nil?
					(@end_time - @begin_time).abs
				else
					0
				end
			end
			
			def task
				@task
			end
			
			def to_h
				h = {}
				h['b'] = @begin_time.strftime(TIME_FORMAT) if !@begin_time.nil?
				h['e'] = @end_time.strftime(TIME_FORMAT) if !@end_time.nil?
				h
			end
			
			def to_s
				'track'
			end
			
			def to_list_s
				end_date = nil
				end_time_s = ''
				if !@end_time.nil?
					end_time_s = !@end_time.nil? ? @end_time.strftime('%R') : 'xx:xx'
					end_date = @end_time.to_date
				end
				
				begin_date_s = ''
				begin_date = @begin_time.to_date
				end_date_s = ''
				if (begin_date != end_date && !end_date.nil?) || !begin_date.today?
					begin_date_s = @begin_time.strftime('%F')
					end_date_s = @end_time.strftime('%F') if !@end_time.nil?
				end
				
				'%10s %5s - %5s %10s    %s' % [begin_date_s, @begin_time.strftime('%R'), end_time_s, end_date_s, @task.to_list_s]
			end
			
			def self.from_h(task, h)
				t = Track.new(task)
				t.begin_time = Time.parse(h['b']).localtime
				t.end_time = Time.parse(h['e']).localtime
				t
			end
			
		end
		
	end
end
