
module TheFox
	module Timr
		
		class TestWindow < Window
			
			def content
				c = []
				(1..30).each do |n|
					c << 'LINE %03d  123456789_123456789_123456789_123456789_123456789_123456789' % [n]
				end
				c
			end
			
		end
		
	end
end
