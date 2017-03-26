
module TheFox
	module Timr
		module Command
			
			class VersionCommand < BasicCommand
				
				def run
					puts "#{TheFox::Timr::NAME} #{TheFox::Timr::VERSION} (#{TheFox::Timr::DATE})"
					puts "#{TheFox::Timr::HOMEPAGE}"
				end
				
			end # class VersionCommand
			
		end # module Command
	end # module Timr
end # module TheFox
