
module TheFox
	module Timr
		
		class TitleView < TheFox::TermKit::TextView
			
			def initialize
				super("#{NAME} #{VERSION}")
			end
			
		end
		
	end
end
