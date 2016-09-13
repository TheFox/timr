
require 'thefox-ext'

module TheFox
	module TermKit
		
		##
		# Base View class
		class View
			
			##
			# The +name+ variable is only for debugging.
			attr_accessor :name
			attr_accessor :parent_view
			attr_accessor :subviews
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
				@parent_view = nil
				@subviews = []
			end
			
			def add_subview(view)
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				@subviews.push(view)
			end
			
			def remove_subview(view)
				if !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				@subviews.delete(view)
			end
			
			def render(force = false, area = nil, level = 0)
				
			end
			
		end
		
	end
end
