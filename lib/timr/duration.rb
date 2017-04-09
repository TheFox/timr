
require 'chronic_duration'

module TheFox
	module Timr
		
		# Uses seconds as basis.
		class Duration
			
			include Error
			
			# Basis Data (Integer)
			# 
			# A Duration is stored as seconds.
			attr_reader :seconds
			
			def initialize(seconds = 0)
				@seconds = seconds.to_i
				
				@smh_seconds = nil
				@smh_minutes = nil
				@smh_hours = nil
			end
			
			# Seconds, Minutes, Hours as Array
			def to_smh
				@smh_seconds = @seconds
				
				@smh_hours = @smh_seconds / 3600
				
				@smh_seconds -= @smh_hours * 3600
				@smh_minutes = @smh_seconds / 60
				
				@smh_seconds -= @smh_minutes * 60
				
				[@smh_seconds, @smh_minutes, @smh_hours]
			end
			
			# Converts seconds to `nh nm ns` format. Where `n` is a number.
			def to_human
				dur_opt = {
					:format => :short,
					:limit_to_hours => true,
					:keep_zero => false,
					:units => 2,
				}
				h = ChronicDuration.output(@seconds, dur_opt)
				
				h ? h : '---'
			end
			
			# Man-days, Man-hours
			# 
			# Man Unit:
			# 
			# - 8 hours are 1 man-day.
			# - 5 man-days are 1 man-week, and so on.
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
			
			# Adds two Durations.
			def +(duration)
				case duration
				when Integer
					Duration.new(@seconds + duration)
				when Duration
					Duration.new(@seconds + duration.seconds)
				when nil
					Duration.new(@seconds)
				else
					raise DurationError, "Wrong type #{duration.class} for '+' function."
				end
			end
			
			# Subtract two Durations.
			def -(duration)
				case duration
				when Integer
					diff = @seconds - duration
				when Duration
					diff = @seconds - duration.seconds
				else
					raise DurationError, "Wrong type #{duration.class} for '+' function."
				end
				
				if diff < 0
					diff = 0
				end
				Duration.new(diff)
			end
			
			# Lesser
			def <(obj)
				case obj
				when Integer
					@seconds < obj
				when Duration
					@seconds < obj.to_i
				end
			end
			
			# Greater
			def >(obj)
				case obj
				when Integer
					@seconds > obj
				when Duration
					@seconds > obj.to_i
				end
			end
			
			# String
			def to_s
				@seconds.to_s
			end
			
			# Use this instead of `Duration.seconds`.
			def to_i
				@seconds
			end
			
			# All methods in this block are static.
			class << self
				
				# Parse a String using [ChronicDuration](https://rubygems.org/gems/chronic_duration) and create a new Duration instance.
				def parse(str)
					Duration.new(ChronicDuration.parse(str))
				end
				
			end
			
		end # class Duration
		
	end # module Timr
end # module TheFox
