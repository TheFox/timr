
module TheFox
	module Timr
		
		class TitleView < TheFox::TermKit::TextView
			
			def initialize
				super("#{NAME} #{VERSION}\n--test")
			end
			
		end
		
	end
end
