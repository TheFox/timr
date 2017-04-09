
module TheFox
	module Timr
		module Helper
			
			# This class helps with Terminal operations.
			class TerminalHelper
				
				# All methods in this block are static.
				class << self
					
					include TheFox::Timr::Error
					
					# Run external editor via EDITOR environment variable.
					def run_external_editor(text = nil)
						case text
						when Array
							text = text.join("\n")
						end
						
						if !ENV['EDITOR'] || ENV['EDITOR'].length == 0
							raise TerminalHelperError, 'EDITOR environment variable not set.'
						end
						
						tmpfile = Tempfile.new('timr_message')
						if text
							tmpfile.write(text)
						end
						tmpfile.close
						
						system_s = '%s %s' % [ENV['EDITOR'], tmpfile.path]
						#puts "start '#{system_s}'"
						system(system_s)
						
						tmpfile.open
						tmpfile_lines = tmpfile.read
						tmpfile.close
						
						tmpfile_lines
							.split("\n")
							.select{ |row| row[0] != '#' }
							.join("\n")
					end
					
					def external_editor_help(edit_text)
						edit_text << '# This is a comment.'
						edit_text << '# The first line should be a sentence. Sentence have dots at the end.'
						edit_text << '# The second line should be empty, if you provide a more detailed'
						edit_text << '# description from on the third line. Like on Git.'
					end
					
				end
				
			end # class TerminalHelper
			
		end # module Helper
	end # module Timr
end # module TheFox
