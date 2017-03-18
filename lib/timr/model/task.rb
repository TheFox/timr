
module TheFox
	module Timr
		
		class Task < Model
			
			attr_reader :description
			attr_reader :tracks
			
			def initialize
				super()
				
				# Meta
				@name = nil
				@description = nil
				@current_track = nil
				
				# Data
				@tracks = Hash.new
			end
			
			def name=(name)
				@name = name
				@changed = true
			end
			
			def name(max_length = nil)
				name = @name
				if name && max_length && name.length > max_length + 2
					name = name[0, max_length] << '...'
				end
				name
			end
			
			def description=(description)
				@description = description
				@changed = true
			end
			
			def pre_save_to_file
				# Meta
				@meta['name'] = @name
				@meta['description'] = @description
				
				@meta['current_track_id'] = nil
				if @current_track
					@meta['current_track_id'] = @current_track.id
				end
				
				# Tracks
				@data = @tracks.map{ |track_id, track|
					#puts "map track: #{track_id} #{track}"
					[track_id, track.to_h]
				}.to_h
				
				super()
			end
			
			def post_load_from_file
				#puts "#{self.class} post_load_from_file"
				
				#puts "#{self.class} data: '#{@data}'"
				
				@tracks = @data.map{ |track_id, track_h|
					#puts "load track #{track_id}"
					
					track = Track.create_track_from_hash(track_h)
					track.task = self
					[track_id, track]
				}.to_h
				
				#puts "tracks loaded: #{@tracks.count}"
				
				current_track_id = @meta['current_track_id']
				if current_track_id
					@current_track = @tracks[current_track_id]
					# if @current_track
					# 	puts "current_track loaded: #{@current_track.short_id}"
					# else
					# 	puts "no current track found"
					# end
				end
				
				@name = @meta['name']
				@description = @meta['description']
			end
			
			def start(options = {})
				puts "#{short_id} Task start"
				
				# Track Options
				options ||= {}
				# options[:date] ||= nil
				# options[:time] ||= nil
				#options[:message] ||= nil
				options[:track_id] ||= nil
				
				# Used by Push to
				options[:no_stop] ||= false
				
				unless options[:no_stop]
					# End current Track before starting a new one.
					# Leave options empty here for stop().
					stop
				end
				
				if options[:track_id]
					puts "find_track_by_id #{options[:track_id]}"
					found_track = find_track_by_id(options[:track_id])
					if found_track
						puts "clone this track: #{found_track.short_id}"
						
						@current_track = found_track.dup
						puts "cloned track: #{@current_track.short_id}"
						
					else
						raise "No Track found for Track ID '#{options[:track_id]}'."
					end
				else
					@current_track = Track.new
					@current_track.task = self
					# puts "new track: #{@current_track.short_id}"
				end
				
				@tracks[@current_track.id] = @current_track
				
				# Mark Task as changed.
				changed
				
				@current_track.start(options)
				@current_track
			end
			
			# Stops a current running Track.
			def stop(options = {})
				options ||= {}
				
				if @current_track
					puts "#{short_id} Task stop"
					
					@current_track.stop(options)
					
					# Reset current Track variable.
					@current_track = nil
					
					# Mark Task as changed.
					changed
				end
			end
			
			# Pauses a current running Track.
			def pause(options = {})
				options ||= {}
				
				if @current_track
					puts "#{short_id} Task pause"
					
					@current_track.stop(options)
					
					# Mark Task as changed.
					changed
				end
			end
			
			# Continues the current Track.
			# Only if it isn't already running.
			def continue(options = {})
				options ||= {}
				
				if @current_track
					if @current_track.stopped?
						puts "Task continue"
						
						track = @current_track.dup
						
						track.start(options)
						
						# Mark Task as changed.
						changed
					end
				else
					# @TODO continue nil current_track
					raise NotImplementedError
				end
			end
			
			def duration(end_datetime = Time.now)
				# t_hours = 0
				# t_minutes = 0
				t_seconds = 0
				@tracks.each do |track_id, track|
					# hours, minutes, seconds = track.duration(end_datetime)
					#puts "#{t_seconds} #{hours}, #{minutes}, #{seconds}"
					#t_seconds += hours * 3600 + minutes * 60 + seconds
					t_seconds += track.duration_seconds
				end
				
				DateTimeHelper.seconds_to_hours(t_seconds)
			end
			
			def duration_s(end_datetime = Time.now)
				'%d:%02d:%02d' % duration(end_datetime)
			end
			
			# Find a Track by ID even if the ID is not 40 characters long.
			# When the ID is 40 characters long @tracks[id] is faster. ;)
			def find_track_by_id(id)
				id_len = id.length
				
				if id_len == 40
					track_id = id
				else
					@tracks.keys.each do |key|
						puts "track id: #{id} #{key}"
						
						if id == key[0, id_len]
							if track_id
								raise "Track ID '#{id}' is not a unique identifier."
							else
								track_id = key
								puts "found track: #{track_id}"
								
								# Do not break the loop here.
								# Iterate all keys to make sure the ID is unique.
							end
						end
					end
				end
				
				@tracks[track_id]
			end
			
			def to_s
				"Task #{@meta['id']}"
			end
			
			def inspect
				"#<Task #{@meta['id']}>"
			end
			
			# All methods in this block are static.
			class << self
				
				# Load a Task from a file into a Task instance.
				def load_task_from_file(path)
					task = Task.new
					# puts "task: #{task.class} #{task} #{self.class} #{class}"
					task.load_from_file(path)
					task
				end
				
				# Search a in a base path for a Track by ID.
				# If found a file load it into a Task instance.
				def load_task_from_file_with_id(base_path, task_id)
					task_file_path = Model.find_file_by_id(base_path, task_id)
					if task_file_path
						load_task_from_file(task_file_path)
					end
				end
				
				def create_task_from_hash(hash)
					task = Task.new
					task.name = hash[:name] # || hash['name']
					task.description = hash[:description] # || hash['description']
					task
				end
				
			end
			
		end # class Task
		
	end # module Timr
end #module TheFox
