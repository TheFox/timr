
require 'time'

module TheFox
	module Timr
		
		class TaskManager
			
			def initialize(base_dir_path)
				#puts "task manager init: #{base_dir_path}"
				
				@base_dir_path = base_dir_path
				@tasks = {}
				@last_write = nil
			end
			
			def load
				#puts "load tasks from #{@base_dir_path}"
				#puts Dir.pwd
				
				Dir.chdir(@base_dir_path) do
					#puts Dir.pwd
					
					Dir['task_*.yml'].each do |file_name|
						#puts "file: '#{file_name}'"
						
						task = Task.new(file_name)
						@tasks[task.id] = task
					end
				end
			end
			
			def save
				#puts "save tasks to #{@base_dir_path}"
				#puts Dir.pwd
				
				@last_write = Time.now
				Dir.chdir(@base_dir_path) do
					#puts Dir.pwd
					
					@tasks.each do |task_id, task|
						file_name = File.expand_path("task_#{task_id}.yml", @base_dir_path)
						#puts "save task to: '#{file_name}'"
						task.save_to_file(file_name)
					end
				end
			end
			
			def stop
				@tasks.each do |task_id, task|
					task.stop
				end
			end
			
			def close
				stop
				save
			end
			
		end
		
	end
end
