
module TheFox
	module TermKit
		
		class KeyEvent
			
			def initialize
				super()
				
				@key = nil
				
				#puts "KeyEvent initialize"
			end
			
			def key=(key)
				@key = key
			end
			
			def key
				@key
			end
			
			def to_s
				"#{self.class}->#{@key}[#{@key.ord}]"
			end
			
		end
		
	end
end
