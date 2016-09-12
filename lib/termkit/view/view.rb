
require 'thefox-ext'

module TheFox
	module TermKit
		
		##
		# Base View class
		class View
			
			##
			# The +name+ variable is only for debugging.
			attr_accessor :name
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
			end
			
			def render(force = false, area = nil, level = 0)
				
			end
			
		end
		
	end
end
