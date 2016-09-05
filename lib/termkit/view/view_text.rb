
module TheFox
	module TermKit
		
		class TextView < View
			
			def initialize(text = nil)
				super("text_view")
				
				#puts 'TextView->initialize'
				
				draw_text(text)
			end
			
			def text=(text)
				if !text.is_a?(String)
					raise ArgumentError, "Argument is not a String -- #{text.class} given"
				end
				
				draw_text(text)
			end
			
			private
			
			def draw_text(text)
				
			end
			
		end
		
	end
end
