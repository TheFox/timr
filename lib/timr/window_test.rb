
module TheFox
	module Timr
		
		class TestWindow < Window
			
			def setup
				@has_cursor = true
				
				@data = []
				(1..30).each do |n|
					@data << 'LINE %03d  123456789_123456789_123456789_123456789_123456789_123456789' % [n]
				end
				@data
			end
			
		end
		
	end
end
