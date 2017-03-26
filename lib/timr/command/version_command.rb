
module TheFox
	module Timr
		module Command
			
			class VersionCommand < BasicCommand
				
				def run
					puts "#{NAME} #{VERSION} (#{DATE})"
					puts "#{HOMEPAGE}"
				end
				
			end # class VersionCommand
			
		end # module Command
	end # module Timr
end # module TheFox
