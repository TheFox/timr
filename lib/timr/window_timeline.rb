
module TheFox
	module Timr
		
		class TimelineWindow < Window
			
			@tasks = nil
			
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
						.map{ |task_id, task|
							task.timeline.map{ |track|
								"#{task} -- #{track}"
							}
						}
						.flatten
				end
			end
			
		end
		
	end
end
