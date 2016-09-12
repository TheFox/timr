
module TheFox
	module TermKit
		
		class ViewContent
			
			attr_accessor :char
			
			def initialize(view, char)
				@view = view
				@char = char[0].clone
			end
			
			def to_s
				char
			end
			
		end
		
	end
end
