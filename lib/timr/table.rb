
module TheFox
	module Timr
		
		class Table
			
			attr_reader :rows
			
			def initialize(options = {})
				@options = options || {}
				#@options[:hide_empty_columns] ||= true
				@options[:headings] ||= Array.new
				
				#@columns = Array.new
				@rows = Array.new
			end
			
			def <<(row)
				# "new row: #{row}"
				col_n = 0
				row.each do |col|
					# "col: #{col_n} #{col}"
					
					header = @options[:headings][col_n]
					if header
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
				#puts
				@rows << row
			end
			
			def to_s
				s = ''
				
				#header_row = []
				s << @options[:headings].map{ |header|
					#puts "build header: '#{header[:label]}'"
					unless header[:empty]
						#('%%-%ds' % [header[:max_length]]) % [header[:label]]
						"%s#{header[:format]}%s" % [header[:padding_left], header[:label], header[:padding_right]]
					end
				}.select{ |s| !s.nil? }.join(' ')
				s << "\n"
				
				@rows.each do |row|
					col_n = 0
					columns = []
					row.each do |col|
						header = @options[:headings][col_n]
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
