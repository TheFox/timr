
require 'termkit'

module TheFox
	module Timr
		
		class TitleView < TheFox::TermKit::TextView
			
			def initialize
				super("#{NAME} #{VERSION}\n--HEADER ZEILE 2--")
			end
			
		end
		
	end
end
