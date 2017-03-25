
module TheFox
	module Timr
		
		class TimrError < StandardError
		end
		
		class ModelError < TimrError
		end
		
		class TaskError < ModelError
		end
		
		class TrackError < ModelError
		end
		
	end # module Timr
end # module TheFox
