
module TheFox
	module Timr
		
		class TasksWindow < Window
			
			def content
				if @data.nil? || @data.length == 0
					@has_cursor = false
					[
						'',
						'#### NO  TASKS YET ####',
						'',
						"Press 'n' to create a new task.",
						"   Or 'h' to jump to the help page.",
					]
				else
					@has_cursor = true
					@data
						.sort_by{ |k, v|
							v.name.downcase
						}
						.map{ |a| a[1] }
				end
			end
			
		end
		
	end
end
