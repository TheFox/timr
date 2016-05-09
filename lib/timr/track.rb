
require 'time'

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
				@tbegin.strftime('%y-%m-%d %H:%M')
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
