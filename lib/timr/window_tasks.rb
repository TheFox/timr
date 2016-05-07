
require 'pp'

module TheFox
	module Timr
		
		class TasksWindow < Window
			
			@tasks = nil
			
			def tasks=(tasks)
				content_changed
				@tasks = tasks
			end
			
			def content
				if @tasks.nil? || @tasks.length == 0
					[
						'',
						'#### NO TASKS YET ####',
						'',
						"Press 'n' to create a new task.",
					]
				else
					@tasks
						.sort_by{ |k, v|
							v.name
						}
						.map{ |a| a[1] }
				end
			end
			
		end
		
	end
end
