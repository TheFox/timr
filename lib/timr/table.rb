
module TheFox
	module Timr
		
		class Table
			
			attr_reader :rows
			
			def initialize(options = Hash.new)
				@headings = options.fetch(:headings, Array.new)
				
				@rows = Array.new
			end
			
			# Append a row.
			def <<(row)
				col_n = 0
				row.each do |col|
					header = @headings[col_n]
					if header
						header[:format] ||= '%s'
						header[:label] ||= ''
						unless header.has_key?(:empty)
							header[:empty] = true
						end
						header[:max_length] ||= 0
						header[:padding_left] ||= ''
						header[:padding_right] ||= ''
					else
						header = {
							:format => '%s',
							:label => '',
							:empty => true,
							:max_length => 0,
							:padding_left => '',
							:padding_right => '',
						}
					end
					
					unless col.nil?
						if header[:empty]
							header[:empty] = false
						end
						col_s = col.to_s
						if col_s.length > header[:max_length]
							header[:max_length] = (header[:format] % [col_s]).length + header[:padding_left].length + header[:padding_right].length
						end
					end
					
					col_n += 1
				end
				@rows << row
			end
			
			# Render Table to String.
			def to_s
				s = ''
				
				s << @headings.map{ |header|
					unless header[:empty]
						#('%%-%ds' % [header[:max_length]]) % [header[:label]]
						"%s#{header[:format]}%s" % [header[:padding_left], header[:label], header[:padding_right]]
					end
				}.select{ |ts| !ts.nil? }.join(' ')
				s << "\n"
				
				@rows.each do |row|
					col_n = 0
					columns = []
					row.each do |col|
						header = @headings[col_n]
						unless header[:empty]
							#s << header[:format] % [col] << ' '
							col_s = "%s#{header[:format]}%s" % [header[:padding_left], col, header[:padding_right]]
							columns << col_s
						end
						col_n += 1
					end
					s << columns.join(' ') << "\n"
				end
				
				s
			end
			
		end # class Task
		
	end # module Timr
end #module TheFox
