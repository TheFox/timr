
# require 'fileutils'
# require 'yaml/store'
require 'pp' # @TODO remove pp
require 'pathname'

module TheFox
	module Timr
		
		class Timr
			
			include Model
			include Error
			
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
			def start(options = Hash.new)
				options ||= Hash.new
				options[:task_id] ||= nil
				options[:track_id] ||= nil
				
				#pp options # @TODO remove pp
				
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
						task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
						
						# Save Track to file.
						task.save_to_file(task_file_path)
						
						@stack.start(track)
						@stack.save_to_file
					end
				end
				
				track
			end
			
			# Stops the current running Track and removes it from the Stack.
			def stop(options = Hash.new)
				options ||= Hash.new
				
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
			def pause(options = Hash.new)
				options ||= Hash.new
				
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
			def continue(options = Hash.new)
				options ||= Hash.new
				
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
			def push(options = Hash.new)
				options ||= Hash.new
				options[:task_id] ||= nil
				options[:track_id] ||= nil
				
				#pp options # @TODO remove pp
				
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
						task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
						
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
			def pop(options = Hash.new)
				options ||= Hash.new
				
				stop(options)
				continue(options)
			end
			
			# Just add a new [Task](rdoc-ref:TheFox::Timr::Model::Task). Will not be started or something else.
			# 
			# Uses [Task.create_task_from_hash](rdoc-ref:TheFox::Timr::Model::Task::create_task_from_hash) to create a new Task instance and [BasicModel.create_path_by_id](rdoc-ref:TheFox::Timr::Model::BasicModel.create_path_by_id) to create a new file path.
			# 
			# Returns the new created Task instance.
			def add_task(options = Hash.new)
				options ||= Hash.new
				
				task = Task.create_task_from_hash(options)
				
				# Task Path
				task_file_path = BasicModel.create_path_by_id(@tasks_path, task.id)
				
				# Save Track to file.
				task.save_to_file(task_file_path)
				
				# Leave Stack untouched.
				
				task
			end
			
			# Remove a Task.
			# 
			# Options:
			# 
			# - `:task_id` (String) 
			def remove_task(options = Hash.new)
				options ||= Hash.new
				options[:task_id] ||= nil
				unless options[:task_id]
					raise TaskError, 'task_id cannot be nil.'
				end
				
				task = get_task_by_id(options[:task_id])
				
				@tasks.delete(task.id)
				
				# Get running Tracks and remove these from Stack.
				task.tracks({:status => ?R}).each do |track_id, track|
					# puts "TRACK: #{track}" # @TODO remove
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
				options ||= Hash.new
				options[:track_id] ||= nil
				
				unless options[:track_id]
					raise TrackError, 'track_id cannot be nil.'
				end
				
				track = get_track_by_id(options[:track_id])
				unless track
					raise TrackError, "Track for ID '#{options[:track_id]}' not found."
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
			
			# Find a Task by ID.
			def get_task_by_id(task_id)
				task = @tasks[task_id]
				
				# puts "Timr get_task_by_id: #{task_id}" # @TODO remove
				
				if task
					# Take Task from cache.
				else
					task = Task.load_task_from_file_with_id(@tasks_path, task_id)
					
					# task_id can be a short ID. If a Task is already loaded with full ID
					# another search by short ID leads to generate a new object_id. Then there are
					# two Tasks instances loaded for the same Task ID. The if-condition prohibits this.
					if @tasks[task.id]
						task = @tasks[task.id]
					else
						@tasks[task.id] = task
					end
				end
				
				# puts "Timr Tasks: #{@tasks.count} #{@tasks.map{|id, t| t.short_id}}" # @TODO remove
				
				task
			end
			
			# Find a Track by ID.
			def get_track_by_id(track_id)
				@tasks.each do |task_id, task|
					# puts "Timr search track: #{task}" # @TODO remove
					
					track = task.find_track_by_id(track_id)
					if track
						return track
					end
				end
				
				nil
			end
			
			# Get all Tasks.
			def tasks
				load_all_tracks
				
				@tasks
			end
			
			# Get all Tracks.
			# 
			# Options:
			# 
			# - `:sort` (Boolean)
			def tracks(options = Hash.new)
				options ||= Hash.new
				unless options.has_key?(:sort)
					options[:sort] = true
				end
				
				load_all_tracks
				
				filtered_tracks = Hash.new
				@tasks.each do |task_id, task|
					# puts "task: #{task} #{task.tracks.count}" # @TODO remove
					
					tracks = task.tracks(options)
					filtered_tracks.merge!(tracks)
					
					# puts "  -> #{filtered_tracks.count}" # @TODO remove
					# puts # @TODO remove
				end
				
				# puts "#{Time.now.to_ms} #{self.class} #{__method__} END #{filtered_tracks.count}" # @TODO remove
				
				if options[:sort]
					# Sort ASC by Begin DateTime, End DateTime.
					filtered_tracks.sort{ |t1, t2|
						t1 = t1.last
						t2 = t2.last
						
						cmp1 = t1.begin_datetime <=> t2.begin_datetime
						#puts "cmp1: #{cmp1}" # @TODO remove
						
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
			
			def shutdown
				# puts 'Timr shutdown'
				
				# Save Stack
				@stack.save_to_file
				
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
