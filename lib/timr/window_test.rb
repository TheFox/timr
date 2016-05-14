
module TheFox
	module Timr
		
		class TestWindow < Window
			
			@lines = nil
			
			def setup
				@has_cursor = true
				@lines = nil
			end
			
			def content=(lines)
				content_changed
				@lines = lines
			end
			
			def content
				if @lines.nil?
					c = []
					(1..30).each do |n|
						c << 'LINE %03d  123456789_123456789_123456789_123456789_123456789_123456789' % [n]
					end
					c
				else
					@lines
				end
			end
			
		end
		
	end
end
