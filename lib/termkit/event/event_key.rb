
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
				ord_s = ''
				if !@key.nil?
					ord_s = "->#{@key.ord}[#{@key}]"
				end
				"#{self.class}#{ord_s}"
			end
			
		end
		
	end
end
