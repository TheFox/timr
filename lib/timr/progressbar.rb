
module TheFox
	module Timr
		
		# See [ruby-progressbar Issue #131](https://github.com/jfelchner/ruby-progressbar/issues/131).
		class ProgressBar
			
			def initialize(options = Hash.new)
				@total = options.fetch(:total, 100)
				@progress = options.fetch(:progress, 0)
				@length = options.fetch(:length, 10)
				@progress_mark = options.fetch(:progress_mark, ?#)
				@remainder_mark = options.fetch(:remainder_mark, ?-)
			end
			
			# Render ProgressBar as String.
			def render(progress = nil)
				if progress
					@progress = progress
				end
				
				progress_f = @progress.to_f / @total.to_f
				if progress_f > 1.0
					progress_f = 1.0
				end
				
				progress_f = @length.to_f * progress_f
				
				progress_s = @progress_mark * progress_f
				
				remain_l = @length - progress_s.length
				
				remain_s = @remainder_mark * remain_l
				
				'%s%s' % [progress_s, remain_s]
			end
			
		end # class ProgressBar
		
	end # module Timr
end # module TheFox
