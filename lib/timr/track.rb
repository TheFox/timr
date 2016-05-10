
require 'time'
require 'thefox-ext'

module TheFox
	module Timr
		
		class Track
			
			def initialize(task, tbegin = Time.now, tend = nil)
				@task = task
				@tbegin = tbegin
				@tend = tend
			end
			
			def begin=(tb)
				@tbegin = tb
			end
			
			def begin
				@tbegin
			end
			
			def end=(te)
				@tend = te
			end
			
			def end
				@tend
			end
			
			def task
				@task
			end
			
			def to_h
				h = {}
				h['b'] = @tbegin.strftime(TIME_FORMAT) if !@tbegin.nil?
				h['e'] = @tend.strftime(TIME_FORMAT) if !@tend.nil?
				h
			end
			
			def to_s
				'track'
			end
			
			def to_list_s
				tend_date = nil
				tend_time_s = ''
				if !@tend.nil?
					tend_time_s = !@tend.nil? ? @tend.strftime('%R') : 'xx:xx'
					tend_date = @tend.to_date
				end
				
				tbegin_date_s = ''
				tbegin_date = @tbegin.to_date
				tend_date_s = ''
				if (tbegin_date != tend_date && !tend_date.nil?) || !tbegin_date.today?
					tbegin_date_s = @tbegin.strftime('%F')
					tend_date_s = @tend.strftime('%F') if !@tend.nil?
				end
				
				'%10s %5s - %5s %10s -- %s' % [tbegin_date_s, @tbegin.strftime('%R'), tend_time_s, tend_date_s, @task.to_list_s]
			end
			
			def self.from_h(task, h)
				t = Track.new(task)
				t.begin = Time.parse(h['b'])
				t.end = Time.parse(h['e'])
				t
			end
			
		end
		
	end
end
