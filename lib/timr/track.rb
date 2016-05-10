
require 'time'
require 'thefox-ext'

module TheFox
	module Timr
		
		class Track
			
			def initialize(tbegin = Time.now, tend = nil)
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
			
			def to_h
				h = {}
				h['b'] = @tbegin.strftime(TIME_FORMAT) if !@tbegin.nil?
				h['e'] = @tend.strftime(TIME_FORMAT) if !@tend.nil?
				h
			end
			
			def to_s
				tbegin_date = @tbegin.to_date
				tend_date = @tend.to_date
				
				tbegin_date_s = ''
				tbegin_time_s = @tbegin.strftime('%R')
				tend_date_s = ''
				tend_time_s = @tend.strftime('%R')
				if tbegin_date != tend_date || !tbegin_date.today?
					tbegin_date_s = @tbegin.strftime('%F')
					tend_date_s = @tend.strftime('%F')
				end
				
				'%10s %5s - %10s %5s' % [tbegin_date_s, tbegin_time_s, tend_date_s, tend_time_s]
			end
			
			def self.from_h(h)
				t = Track.new
				t.begin = Time.parse(h['b'])
				t.end = Time.parse(h['e'])
				t
			end
			
		end
		
	end
end
