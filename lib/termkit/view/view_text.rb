
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
				@text = text
				if !@text.nil?
					y = 0
					@text.split("\n").each do |row|
						#puts "row #{y} '#{row}'"
						
						x = 0
						row.length.times.each do |n|
							#puts "  %3d %3d %3d '%s'" % [y, n, x, row[n]]
							
							draw_point(Point.new(x, y), row[n])
							
							x += 1
						end
						
						y += 1
					end
				end
			end
			
		end
		
	end
end
