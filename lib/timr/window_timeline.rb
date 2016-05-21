
module TheFox
	module Timr
		
		class TimelineWindow < Window
			
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
						'#### NO TRACKS YET ####',
						'',
						"Press 'n' to create a new task.",
						"   Or 'h' to jump to the help page.",
					]
				else
					@has_cursor = true
					@tasks
						.map{ |task_id, task|
							task.timeline
						}
						.flatten
						.sort{ |task_a, task_b|
							task_a.begin_time <=> task_b.begin_time || task_a.end_time <=> task_b.end_time
						}
				end
			end
			
		end
		
	end
end
