
require 'pathname'

module TheFox
	module Timr
		
		# Core Class
		# 
		# Loads and saves Models to files. Tasks are loaded to `@tasks`.
		# 
		# Holds the [Stack](rdoc-ref:TheFox::Timr::Model::Stack) instance. Responsible to call Stack methods.
		class Timr
			
			include Model
			include Error
			
			# Stack instance.
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
				
				# Stack
				@stack = Stack.new
				@stack.timr = self
				@stack.file_path = stack_path
				if stack_path.exist?
					@stack.load_from_file
				end
			end
			
			# Removes all previous [Tracks](rdoc-ref:TheFox::Timr::Model::Track) and starts a new one.
			def start(options = Hash.new)
				task_id_opt = options.fetch(:task_id, nil)
				track_id_opt = options.fetch(:track_id, nil)
				
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
				
				if task_id_opt
					task = get_task_by_id(task_id_opt)
					
					track = task.start(options)
					
					task.save_to_file
					
					@stack.start(track)
					@stack.save_to_file
				else
					if track_id_opt
						# The long way. Should be avoided.
						# Search all files.
						
						track = Track.find_track_by_id(@tasks_path, track_id_opt)
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
							
							@stack.start(track)
							@stack.save_to_file
						end
					else
						# Create completely new Task.
						task = Task.create_task_from_hash(options)
						
						# Start Task
						track = task.start(options)
						
						# Task Path
						task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
						
						# Save Track to file.
						task.save_to_file(task_file_path)
						
						@stack.start(track)
						@stack.save_to_file
					end
				end
				
				track
			end
			
			# Stops the current running [Track](rdoc-ref:TheFox::Timr::Model::Track) and removes it from the Stack.
			def stop(options = Hash.new)
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
			
			# Stops the current running [Track](rdoc-ref:TheFox::Timr::Model::Track) but does not remove it from the Stack.
			def pause(options = Hash.new)
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
			
			# Continues the Top [Track](rdoc-ref:TheFox::Timr::Model::Track).
			def continue(options = Hash.new)
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
			
			# Starts a new [Track](rdoc-ref:TheFox::Timr::Model::Track) and pauses the underlying one.
			def push(options = Hash.new)
				task_id_opt = options.fetch(:task_id, nil)
				track_id_opt = options.fetch(:track_id, nil)
				
				# Get current Track from Stack.
				old_track = @stack.current_track
				
				# Stop current running Track.
				if old_track
					# Get Task from Track.
					old_task = old_track.task
					unless old_task
						raise TrackError, "Track #{old_track.short_id} has no Task."
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
				
				if task_id_opt
					task = get_task_by_id(task_id_opt)
					
					# Start Task
					track = task.start(options)
					
					# Save Task
					task.save_to_file
					
					@stack.push(track)
					@stack.save_to_file
				else
					if track_id_opt
						# The long way. Should be avoided.
						# Search all files.
						
						track = Track.find_track_by_id(@tasks_path, track_id_opt)
						if track
							options[:track_id] = track.id
							
							# Get Task from Track.
							task = track.task
							unless task
								raise TrackError, "Track #{track.short_id} has no Task."
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
						task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
						
						# Save Track to file.
						task.save_to_file(task_file_path)
						
						@stack.push(track)
						@stack.save_to_file
					end
				end
				
				track
			end
			
			# Stops the Top [Track](rdoc-ref:TheFox::Timr::Model::Track), removes it from the [Stack](rdoc-ref:TheFox::Timr::Model::Stack) and
			# continues the next underlying (new Top) Track.
			def pop(options = Hash.new)
				stop(options)
				continue(options)
			end
			
			# Create a new [Task](rdoc-ref:TheFox::Timr::Model::Task) based on the `options` Hash. Will not be started or something else.
			# 
			# Uses [Task#create_task_from_hash](rdoc-ref:TheFox::Timr::Model::Task::create_task_from_hash) to create a new Task instance and [BasicModel#create_path_by_id](rdoc-ref:TheFox::Timr::Model::BasicModel.create_path_by_id) to create a new file path.
			# 
			# Returns the new created Task instance.
			def add_task(options = Hash.new)
				task = Task.create_task_from_hash(options)
				
				# Task Path
				task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
				
				# Save Track to file.
				task.save_to_file(task_file_path)
				
				# Leave Stack untouched.
				
				task
			end
			
			# Remove a [Task](rdoc-ref:TheFox::Timr::Model::Task).
			# 
			# Options:
			# 
			# - `:task_id` (String) 
			def remove_task(options = Hash.new)
				task_id_opt = options.fetch(:task_id, nil)
				
				unless task_id_opt
					raise TaskError, 'No Task ID given.'
				end
				
				task = get_task_by_id(task_id_opt)
				
				@tasks.delete(task.id)
				
				# Get running Tracks and remove these from Stack.
				task.tracks({:status => ?R}).each do |track_id, track|
					@stack.remove(track)
				end
				@stack.save_to_file
				
				task.delete_file
				
				task
			end
			
			# Remove a Track.
			# 
			# Options:
			# 
			# - `:track_id` (String) 
			def remove_track(options = Hash.new)
				track_id_opt = options.fetch(:track_id, nil)
				
				unless track_id_opt
					raise TrackError, 'No Track ID given.'
				end
				
				track = get_track_by_id(track_id_opt)
				unless track
					raise TrackError, "Track for ID '#{track_id_opt}' not found."
				end
				
				task = track.task
				
				track.remove
				
				task.save_to_file
				
				# Remove Track from Stack.
				@stack.remove(track)
				@stack.save_to_file
				
				{
					:task => task,
					:track => track,
				}
			end
			
			# Find a [Task](rdoc-ref:TheFox::Timr::Model::Task) by ID.
			# 
			# Tasks always should be loaded with this methods to check if a Task instance already exist at `@tasks`. This is like a cache.
			# 
			# `task_id` can be a short ID. If a Task is already loaded with full ID another search by short ID would lead to generate a new object_id. Then there would be two Tasks instances loaded for the same Task ID. The Check Cache if condition prohibits this.
			def get_task_by_id(task_id)
				task = @tasks[task_id]
				
				if task
					# Take Task from cache.
				else
					task = Task.load_task_from_file_with_id(@tasks_path, task_id)
					
					# Check cache.
					if @tasks[task.id]
						# Task already loaded.
						task = @tasks[task.id]
					else
						# Set new loaded Task.
						@tasks[task.id] = task
					end
				end
				
				task
			end
			
			# Find a [Track](rdoc-ref:TheFox::Timr::Model::Track) by ID.
			def get_track_by_id(track_id)
				@tasks.each do |task_id, task|
					track = task.find_track_by_id(track_id)
					if track
						return track
					end
				end
				
				nil
			end
			
			# Get all [Tasks](rdoc-ref:TheFox::Timr::Model::Task).
			def tasks
				load_all_tracks
				
				@tasks
			end
			
			# Get all [Tracks](rdoc-ref:TheFox::Timr::Model::Track).
			# 
			# Options:
			# 
			# - `:sort` (Boolean)
			def tracks(options = Hash.new)
				sort_opt = options.fetch(:sort, true)
				
				load_all_tracks
				
				filtered_tracks = Hash.new
				@tasks.each do |task_id, task|
					tracks = task.tracks(options)
					filtered_tracks.merge!(tracks)
				end
				
				if sort_opt
					# Sort ASC by Begin DateTime, End DateTime.
					filtered_tracks.sort{ |t1, t2|
						t1 = t1.last
						t2 = t2.last
						
						cmp1 = t1.begin_datetime <=> t2.begin_datetime
						
						if cmp1 == 0
							t1.end_datetime <=> t2.end_datetime
						else
							cmp1
						end
					}.to_h
				else
					filtered_tracks
				end
			end
			
			# Save [Stack](rdoc-ref:TheFox::Timr::Model::Stack) and [Config](rdoc-ref:TheFox::Timr::Model::Config).
			def shutdown
				# Save Stack
				@stack.save_to_file
				
				# Save config
				@config.save_to_file
			end
			
			# Load all [Tracks](rdoc-ref:TheFox::Timr::Model::Track) using `get_task_by_id`.
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
					
					track_id = BasicModel.get_id_from_path(@tasks_path, file)
					
					# Loads the Task from file into @tasks.
					get_task_by_id(track_id)
				end
			end
			
			def to_s
				'Timr'
			end
			
		end # class Timr
	
	end # module Timr
end # module TheFox
