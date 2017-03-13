
# require 'fileutils'
# require 'yaml/store'
require 'pp'
require 'pathname'

module TheFox
	module Timr
		
		class Timr
			
			attr_reader :stack
			
			def initialize(cwd)
				# Current Working Directory
				@cwd = cwd
				
				@tasks_path = Pathname.new('tasks').expand_path(@cwd)
				unless @tasks_path.exist?
					@tasks_path.mkpath
				end
				
				# Holds all loaded Tasks.
				@tasks = Hash.new
				
				# Stack Path
				stack_path = Pathname.new('stack.yml').expand_path(@cwd)
				puts "stack path: #{stack_path}"
				
				# Stack
				@stack = Stack.new
				@stack.timr = self
				# @stack.tasks_path = @tasks_path
				@stack.file_path = stack_path
				if stack_path.exist?
					puts "load stack from file"
					@stack.load_from_file
				end
				
				puts "timr for stack: #{@stack.timr}"
			end
			
			# Removes all previous Tracks and starts a new one.
			def start(options = {})
				options ||= {}
				options[:task_id] ||= nil
				options[:track_id] ||= nil
				
				# Get current Track from Stack.
				track = @stack.current_track
				
				# Stop current running Track.
				if track
					# Get Task from Track.
					task = track.task
					unless task
						raise "Track #{track.short_id} has no Task."
					end
					
					# Stop Task
					task.stop
					
					# Save Task
					task.save_to_file
				end
				
				if options[:task_id]
					task = get_task_by_id(options[:task_id])
					
					track = task.start(options)
					puts "new task: #{task.id}"
					
					#puts "save"
					task.save_to_file
					
					#puts "start to stack: #{track}"
					@stack.start(track)
					@stack.save_to_file
				else
					if options[:track_id]
						# The long way. Should be avoided.
						# Search all files.
						
						# track = Track.find_track_by_id(options[:track_id])
						# if track
						# 	track = task.start(options)
						# 	puts "new task: #{task.id}"
							
						# 	puts "save"
						# 	task.save_to_file
							
						# 	puts "start to stack: #{track}"
						# 	@stack.start(track)
						# 	@stack.save_to_file
						# end
					else
						# Create completely new Task.
						task = Task.create_task_from_hash(options)
						#puts "new task: #{task.id}"
						
						track = task.start(options)
						
						# Save Track to file.
						task_file_path = Model.create_path_by_id(@tasks_path, task.id)
						#puts "path: #{task_file_path}"
						
						#puts "save"
						task.save_to_file(task_file_path)
						
						#puts "start to stack: #{track}"
						@stack.start(track)
						@stack.save_to_file
					end
				end
				
				track
			end
			
			# Stops the current running Track and removes it from the Stack.
			def stop(options = {})
				options ||= {}
				
				# Get current Track from Stack.
				track = @stack.current_track
				unless track
					return
				end
				
				# Get Task from Track.
				task = track.task
				
				# Stop Task
				task.stop(options)
				
				# Save Task
				task.save_to_file
				
				@stack.stop
				@stack.save_to_file
				
				track
			end
			
			# Stops the current running Track but does not remove it from the Stack.
			def pause(options = {})
				options ||= {}
				
				# Get current Track from Stack.
				track = @stack.current_track
				unless track
					return
				end
				
				# Get Task from Track.
				task = track.task
				
				# Pause Task
				task.pause(options)
			end
			
			# Continues the Top Track.
			def continue(options = {})
				options ||= {}
				
				# Get current Track from Stack.
				track = @stack.current_track
				unless track
					return
				end
				
				# Get Task from Track.
				task = track.task
				
				# Continue Task
				task.continue(options)
			end
			
			# Starts a new Track and pauses the underlying one.
			def push
			end
			
			# Stops the Top Track, removes it from the Stack and
			# continues the next underlying (new Top) Track.
			def pop
			end
			
			def get_task_by_id(id)
				task = @tasks[id]
				
				if task
					puts "take task from cache: #{id}"
					puts "tracks: #{task.tracks.count}"
				else
					task = Task.load_task_from_file_with_id(@tasks_path, id)
					@tasks[task.id] = task
				end
				
				task
			end
			
			def to_s
				'Timr'
			end
			
		end # class Timr
	
	end # module Timr
end # module TheFox
