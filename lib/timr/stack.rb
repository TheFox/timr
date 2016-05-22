
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
			
			def size
				@tasks.length
			end
			
			def tasks_texts
				@tasks.map{ |task|
					status = task.status
					status = '*' if task == @task
					
					task_name = task.to_s
					task_name = task.track.name if task.has_track?
					
					"#{status} #{task_name}"
				}
			end
			
			def pop
				old = @tasks.pop
				if !old.nil?
					old.stop
					@task = @tasks.last
					@task.start if !@task.nil?
					true
				else
					false
				end
			end
			
			def pop_all(new_task = nil, parent_track = nil)
				if @task == new_task
					#puts 'tasks =='
					x = @task.start(parent_track)
					#puts "return #{x}"
					#puts
					x
				else
					#puts 'stop all tasks'
					@tasks.each do |task|
						task.stop
					end
					@tasks = []
					@task = nil
					
					if !new_task.nil?
						push(new_task, parent_track)
					end
					true
				end
			end
			
			def push(task, parent_track = nil)
				if !@tasks.include?(task)
					@task.pause if has_task?
					
					@task = task
					@task.start(parent_track)
					@tasks << @task
					true
				else
					false
				end
			end
			
		end
		
	end
end
