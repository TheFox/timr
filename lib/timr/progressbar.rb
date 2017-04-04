
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
				
				# puts "ProgressBar: #{@progress} / #{@total}" # @TODO remove
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
				
				# puts "progress_f #{progress_f}" # @TODO remove
				
				progress_f = @length.to_f * progress_f
				# puts "progress_f #{progress_f}" # @TODO remove
				
				progress_s = @progress_mark * progress_f
				# puts "progress_s '#{progress_s}'" # @TODO remove
				
				remain_l = @length - progress_s.length
				# puts "remain_l '#{remain_l}'" # @TODO remove
				
				remain_s = @remainder_mark * remain_l
				# puts "remain_s '#{remain_s}'" # @TODO remove
				
				'%s%s' % [progress_s, remain_s]
			end
			
		end # class ProgressBar
		
	end # module Timr
end # module TheFox
