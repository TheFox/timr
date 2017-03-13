
module TheFox
	module Timr
		
		class VersionCommand < Command
			
			def run
				puts "#{TheFox::Timr::NAME} #{TheFox::Timr::VERSION} (#{TheFox::Timr::DATE})"
				puts "#{TheFox::Timr::HOMEPAGE}"
			end
			
		end # class VersionCommand
	
	end # module Timr
end # module TheFox
