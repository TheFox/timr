
module TheFox
	module Timr
		module Helper
			
			class TranslationHelper
				
				# All methods in this block are static.
				class << self
					
					# Based on the number `n` return singular or plural of a given word.
					# 
					# For example:
					# 
					# ```
					# pluralize(1, 'track', 'tracks')
					# => "1 track"
					# ```
					# 
					# ```
					# pluralize(2, 'track', 'tracks')
					# => "2 tracks"
					# ```
					# 
					# ```
					# pluralize(0, 'track', 'tracks')
					# => "0 tracks"
					# ```
					def pluralize(n, singular, plural=nil)
						if n == 1
							"1 #{singular}"
						elsif plural
							"#{n} #{plural}"
						else
							"#{n} #{singular}s"
						end
					end
					
				end
				
			end # class TranslationHelper
			
		end # module Helper
	end # module Timr
end # module TheFox
