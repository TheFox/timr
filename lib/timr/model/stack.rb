
require 'termkit'

module TheFox
	module Timr
		
		class Stack < TheFox::TermKit::Model
			
			attr_reader :task
			
			def initialize
				super()
				
				#puts 'Stack initialize'
				
				@tasks = []
				@task = nil
			end
			
			def has_task?
				!@task.nil?
			end
			
			def size
				@tasks.length
			end
			
			def tasks_texts
				@tasks.map do |task|
					status = task.status
					status = '*' if task == @task
					
					task_name = task.to_s
					task_name = task.track.name if task.has_track?
					
					"#{status} #{task_name}"
				end
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
					@task.start(parent_track)
				else
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
