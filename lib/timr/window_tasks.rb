
require 'pp'

module TheFox
	module Timr
		
		class TasksWindow < Window
			
			@tasks = nil
			
			def setup
				@tasks = nil
			end
			
			def tasks=(tasks)
				content_changed
				@tasks = tasks
			end
			
			def content
				if @tasks.nil? || @tasks.length == 0
					@has_cursor = false
					[
						'',
						'#### NO TASKS YET ####',
						'',
						"Press 'n' to create a new task.",
					]
				else
					@has_cursor = true
					@tasks
						.sort_by{ |k, v|
							v.name.downcase
						}
						.map{ |a| a[1] }
				end
			end
			
		end
		
	end
end
