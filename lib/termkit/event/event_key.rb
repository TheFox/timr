
module TheFox
	module TermKit
		
		class KeyEvent
			
			attr_accessor :key
			
			def initialize
				super()
				
				@key = nil
				
				#puts "KeyEvent initialize"
			end
			
			def to_s
				"#{self.class}->#{@key}[#{@key.ord}]"
			end
			
		end
		
	end
end
