
module TheFox
	module Timr
		
		class TimelineWindow < Window
			
			def content
				if @data.nil? || @data.length == 0
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
					@data
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
