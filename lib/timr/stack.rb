
module TheFox
	module Timr
		
		class Stack
			
			def initialize
				@tasks = []
				@task = nil
			end
			
			def task
				@task
			end
			
			def has_task?
				!@task.nil?
			end
			
			def length
				@tasks.length
			end
			
			def tasks_texts
				show_star = length > 1
				@tasks.map{ |task|
					status = task.status
					status = '*' if task == @task
					"#{status} #{task}"
				}
			end
			
			def pop
				old = @tasks.pop
				if !old.nil?
					old.stop
					@task = @tasks.last
					@task.start if has_task?
					true
				else
					false
				end
			end
			
			def pop_all(new_task = nil)
				if @task != new_task
					@tasks.each do |task|
						task.stop
					end
					@tasks = []
					@task = nil
					
					if !new_task.nil?
						push(new_task)
					end
				end
			end
			
			def push(task)
				if !@tasks.include?(task)
					@task.stop if has_task?
					
					@task = task
					@task.start
					@tasks << @task
				end
			end
			
		end
		
	end
end
