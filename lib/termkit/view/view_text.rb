
module TheFox
	module TermKit
		
		class TextView < View
			
			def initialize(text = nil)
				super()
				
				@text = text
				process_text
			end
			
			def text=(text)
				if !text.is_a?(String)
					raise "text is of wrong class: #{text.class}"
				end
				
				@text = text
				process_text
			end
			
			private
			
			def process_text
				if !@text.nil?
					y = 0
					@text.split("\n").each do |row|
						#puts "row #{y} '#{row}'"
						
						x = 0
						row.length.times.each do |n|
							#puts "  %3d %3d %3d '%s'" % [y, n, x, row[n]]
							
							set_point(Point.new(x, y), row[n])
							
							x += 1
						end
						
						y += 1
					end
				end
			end
			
		end
		
	end
end
