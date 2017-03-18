
module TheFox
	module Timr
		
		class TranslationHelper
			
			# All methods in this block are static.
			class << self
				
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
			
		end # class DateTimeHelper
		
	end # module Timr
end # module TheFox
