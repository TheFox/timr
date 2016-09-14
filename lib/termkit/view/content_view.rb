
module TheFox
	module TermKit
		
		class ViewContent
			
			attr_accessor :char
			attr_accessor :view
			
			def initialize(char, view = nil)
				@char = char[0]
				@view = view
			end
			
			def to_s
				@char
			end
			
		end
		
	end
end
