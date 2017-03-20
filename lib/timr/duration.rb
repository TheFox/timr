
module TheFox
	module Timr
		
		class Duration
			
			attr_reader :seconds
			
			def initialize(seconds = 0)
				@seconds = seconds
				
				@smh_seconds = nil
				@smh_minutes = nil
				@smh_hours = nil
			end
			
			# Seconds, Minutes, Hours
			def to_smh
				@smh_seconds = @seconds
				
				@smh_hours = @smh_seconds / 3600
				
				@smh_seconds -= @smh_hours * 3600
				@smh_minutes = @smh_seconds / 60
				
				@smh_seconds -= @smh_minutes * 60
				
				[@smh_seconds, @smh_minutes, @smh_hours]
			end
			
			def to_human
				if @smh_seconds.nil? || @smh_minutes.nil? || @smh_hours.nil?
					to_smh
				end
				
				if @smh_hours > 160
					'%d h' % [@smh_hours]
				elsif @smh_hours > 0
					'%dh %dm' % [@smh_hours, @smh_minutes]
				elsif @smh_minutes > 0
					'%dm %ds' % [@smh_minutes, @smh_seconds]
				elsif @smh_seconds > 0
					'%ds' % [@smh_seconds]
				else
					'--'
				end
			end
			
			def to_man_days
				if @seconds < 28800 # 8 * 3600 = 1 man-day
					to_human
				elsif @seconds < 144000 # 5 * 28800 = 1 man-week
					seconds = @seconds
					
					man_days = seconds / 28800
					
					seconds -= man_days * 28800
					man_hours = seconds / 3600
					
					'%dd %dh' % [man_days, man_hours]
				else
					seconds = @seconds
					
					man_weeks = seconds / 144000
					
					seconds -= man_weeks * 144000
					man_days = seconds / 28800
					
					seconds -= man_days * 28800
					man_hours = seconds / 3600
					
					'%dw %dd %dh' % [man_weeks, man_days, man_hours]
				end
			end
			
			def +(duration)
				unless duration.is_a?(Duration)
					raise ArgumentError, "Wrong type #{duration.class}."
				end
				
				Duration.new(@seconds + duration.seconds)
			end
			
			def to_s
				@seconds.to_s
			end
			
			def to_i
				@seconds
			end
			
		end # class Duration
		
	end # module Timr
end # module TheFox
