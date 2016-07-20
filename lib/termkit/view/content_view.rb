
module TheFox
	module TermKit
		
		class ViewContent
			
			def initialize(start_x, content)
				@start_x = start_x
				@content = content
			end
			
			def start_x
				@start_x
			end
			
			def content
				@content
			end
			
			def append(content)
				@content << content
			end
			
			def to_s
				@content
			end
			
		end
		
	end
end
