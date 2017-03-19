
# require 'fileutils'
# require 'yaml/store'
require 'pp' # @TODO remove pp
require 'pathname'

module TheFox
	module Timr
		
		class Timr
			
			attr_reader :stack
			
			def initialize(cwd)
				# Current Working Directory
				@cwd = cwd
				
				@config = Config.new
				@config.file_path = Pathname.new('config.yml').expand_path(@cwd)
				if @config.file_path.exist?
					@config.load_from_file
				else
					#@config.save_to_file
					@config.save_to_file(nil, true)
				end
				
				@tasks_path = Pathname.new('tasks').expand_path(@cwd)
				unless @tasks_path.exist?
					@tasks_path.mkpath
				end
				
				# Holds all loaded Tasks.
				@tasks = Hash.new
				
				# Stack Path
				stack_path = Pathname.new('stack.yml').expand_path(@cwd)
				# puts "stack path: #{stack_path}"
				
				# Stack
				@stack = Stack.new
				@stack.timr = self
				# @stack.tasks_path = @tasks_path
				@stack.file_path = stack_path
				if stack_path.exist?
					# puts "load stack from file"
					@stack.load_from_file
				end
				
				# puts "timr for stack: #{@stack.timr}"
			end
			
			# Removes all previous Tracks and starts a new one.
			def start(options = {})
				options ||= {}
				options[:task_id] ||= nil
				options[:track_id] ||= nil
				
				#pp options
				
				# Get current Track from Stack.
				old_track = @stack.current_track
				
				# Stop current running Track.
				if old_track
					# Get Task from Track.
					old_task = old_track.task
					unless old_task
						raise "Track #{old_track.short_id} has no Task."
					end
					
					# Stop Task
					old_task.stop
					
					# Save Task
					old_task.save_to_file
					
					old_task = nil
				end
				
				if options[:task_id]
					task = get_task_by_id(options[:task_id])
					
					track = task.start(options)
					# puts "new task: #{task.id}"
					
					#puts "save"
					task.save_to_file
					
					#puts "start to stack: #{track}"
					@stack.start(track)
					@stack.save_to_file
				else
					if options[:track_id]
						# The long way. Should be avoided.
						# Search all files.
						
						# puts 'the long way'
						
						track = Track.find_track_by_id(@tasks_path, options[:track_id])
						if track
							# puts "track: #{track.id}"
							options[:track_id] = track.id
							
							# Get Task from Track.
							task = track.task
							unless task
								raise "Track #{track.short_id} has no Task."
							end
							
							# Start Task
							track = task.start(options)
							
							# Save Task
							task.save_to_file
							
							#puts "start to stack: #{track}"
							@stack.start(track)
							@stack.save_to_file
						end
					else
						# Create completely new Task.
						task = Task.create_task_from_hash(options)
						
						# Start Task
						track = task.start(options)
						
						# Task Path
						task_file_path = Model.create_path_by_id(@tasks_path, task.id)
						
						# Save Track to file.
						task.save_to_file(task_file_path)
						
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
				
				# Track Status
				if track.stopped?
					raise "Current Track #{track.short_id} is not running."
				end
				
				# Get Task from Track.
				task = track.task
				
				# Pause Task
				track = task.pause(options)
				
				# Save Task
				task.save_to_file
				
				# Do nothing on the Stack.
				
				track
			end
			
			# Continues the Top Track.
			def continue(options = {})
				options ||= {}
				
				# Get current Track from Stack.
				track = @stack.current_track
				unless track
					return
				end
				options[:track] = track
				
				# Get Task from Track.
				task = track.task
				
				# Continue Task
				track = task.continue(options)
				
				# Save Task
				task.save_to_file
				
				@stack.stop
				@stack.push(track)
				@stack.save_to_file
				
				track
			end
			
			# Starts a new Track and pauses the underlying one.
			def push(options = {})
				options ||= {}
				options[:task_id] ||= nil
				options[:track_id] ||= nil
				
				#pp options
				
				# Get current Track from Stack.
				old_track = @stack.current_track
				
				# Stop current running Track.
				if old_track
					# Get Task from Track.
					old_task = old_track.task
					unless old_task
						raise "Track #{old_track.short_id} has no Task."
					end
					
					# Stop Task here because on pop we need to take the
					# current Track from Stack instead from Task.
					# You can push another Track from an already existing
					# Task on the Stack. A Task can hold only one current Track.
					old_task.stop
					
					# Save Task
					old_task.save_to_file
					
					old_task = nil
				end
				
				if options[:task_id]
					puts "get_task_by_id(#{options[:task_id]})"
					task = get_task_by_id(options[:task_id])
					
					# Start Task
					puts "start task"
					track = task.start(options)
					
					# Save Task
					task.save_to_file
					
					@stack.push(track)
					@stack.save_to_file
				else
					if options[:track_id]
						# The long way. Should be avoided.
						# Search all files.
						
						track = Track.find_track_by_id(@tasks_path, options[:track_id])
						if track
							options[:track_id] = track.id
							
							# Get Task from Track.
							task = track.task
							unless task
								raise "Track #{track.short_id} has no Task."
							end
							
							# Start Task
							track = task.start(options)
							
							# Save Task
							task.save_to_file
							
							@stack.push(track)
							@stack.save_to_file
						end
					else
						# Create completely new Task.
						task = Task.create_task_from_hash(options)
						
						# Start Task
						track = task.start(options)
						
						# Task Path
						task_file_path = Model.create_path_by_id(@tasks_path, task.id)
						
						# Save Track to file.
						task.save_to_file(task_file_path)
						
						@stack.push(track)
						@stack.save_to_file
					end
				end
				
				track
			end
			
			# Stops the Top Track, removes it from the Stack and
			# continues the next underlying (new Top) Track.
			def pop(options = {})
				options ||= {}
				
				stop(options)
				continue(options)
			end
			
			def get_task_by_id(id)
				task = @tasks[id]
				
				if task
					# Take Task from cache.
				else
					task = Task.load_task_from_file_with_id(@tasks_path, id)
					@tasks[task.id] = task
				end
				
				task
			end
			
			def tracks(options = {})
				options ||= {}
				# options[:from] ||= nil
				# options[:to] ||= nil
				
				# options[:from] = nil # @TODO remove
				# options[:to] = nil # @TODO remove
				
				load_all_tracks
				
				filtered_tracks = Hash.new
				
				@tasks.each do |task_id, task|
					puts "task: #{filtered_tracks.count} #{task} #{task_id} #{task.short_id}"
					tracks = task.tracks(options)
					filtered_tracks.merge!(tracks)
					puts "  -> #{filtered_tracks.count}"
					puts
				end
				
				filtered_tracks
			end
			
			def shutdown
				# puts 'Timr shutdown'
				
				# Save config
				@config.save_to_file
			end
			
			def load_all_tracks
				# Iterate all files.
				@tasks_path.find.each do |file|
					# Filter all directories.
					unless file.file?
						next
					end
					
					# Filter all non-yaml files.
					unless file.basename.fnmatch('*.yml')
						next
					end
					
					id = Model.get_id_from_path(@tasks_path, file)
					
					# Loads the Task from file into @tasks.
					get_task_by_id(id)
				end
			end
			
			def to_s
				'Timr'
			end
			
		end # class Timr
	
	end # module Timr
end # module TheFox
