
require 'time'
require 'thefox-ext'

module TheFox
	module Timr
		
		class Track
			
			def initialize(task = nil, begin_time = Time.now, end_time = nil)
				@task = task
				@begin_time = begin_time
				@end_time = end_time
			end
			
			def task
				@task
			end
			
			def begin_time=(begin_time)
				@begin_time = nil
				@begin_time = begin_time.utc if !begin_time.nil?
			end
			
			def begin_time
				if !@begin_time.nil?
					@begin_time.localtime
				else
					nil
				end
			end
			
			def end_time=(end_time)
				@end_time = nil
				@end_time = end_time.utc if !end_time.nil?
			end
			
			def end_time
				if !@end_time.nil?
					@end_time.localtime
				else
					nil
				end
			end
			
			def diff
				if !@begin_time.nil? && !@end_time.nil?
					(@end_time - @begin_time).abs.to_i
				else
					0
				end
			end
			
			def to_h
				h = {
					'b' => nil,
					'e' => nil,
				}
				h['b'] = @begin_time.utc.strftime(TIME_FORMAT) if !@begin_time.nil?
				h['e'] = @end_time.utc.strftime(TIME_FORMAT) if !@end_time.nil?
				h
			end
			
			def to_s
				'track'
			end
			
			def to_list_s
				end_date = nil
				end_time_s = 'xx:xx'
				if !@end_time.nil?
					end_date = @end_time.localtime.to_date
					end_time_s = @end_time.localtime.strftime('%R')
				end
				
				begin_date_s = ''
				begin_date = @begin_time.localtime.to_date
				end_date_s = ''
				if (begin_date != end_date && !end_date.nil?) || !begin_date.today?
					begin_date_s = @begin_time.localtime.strftime('%F')
					end_date_s = @end_time.localtime.strftime('%F') if !@end_time.nil?
				end
				
				task_name = ''
				if !@task.nil?
					task_name = @task.to_list_s
				end
				
				'%10s %5s - %5s %10s    %s' % [begin_date_s, @begin_time.localtime.strftime('%R'), end_time_s, end_date_s, task_name]
			end
			
			def self.from_h(task = nil, h)
				t = Track.new(task, nil)
				t.begin_time = Time.parse(h['b']) if h.has_key?('b')
				t.end_time   = Time.parse(h['e']) if h.has_key?('e')
				t
			end
			
		end
		
	end
end
