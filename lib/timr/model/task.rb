
module TheFox
	module Timr
		module Model
			
			class Task < BasicModel
				
				include TheFox::Timr::Error
				
				attr_reader :description
				
				def initialize
					super()
					
					# Meta
					@name = nil
					@description = nil
					@current_track = nil
					
					# Data
					@tracks = Hash.new
				end
				
				# Set name.
				def name=(name)
					@name = name
					
					# Mark Task as changed.
					changed
				end
				
				# Get name.
				def name(max_length = nil)
					name = @name
					if name && max_length && name.length > max_length + 2
						name = name[0, max_length] << '...'
					end
					name
				end
				
				# Get name or '-' if name is not set.
				def name_s(max_length = nil)
					s = name(max_length)
					if s.nil?
						'-'
					else
						s
					end
				end
				
				def description=(description)
					@description = description
					
					# Mark Task as changed.
					changed
				end
				
				def add_track(track)
					track.task = self
					
					@tracks[track.id] = track
					
					# Mark Task as changed.
					changed
				end
				
				def remove_track(track)
					track.task = nil
					
					@tracks.delete(track.id)
					
					# Mark Task as changed.
					changed
				end
				
				# Move a Track to another Task.
				def move_track(track, target_task)
					if eql?(target_task)
						return false
					end
					
					remove_track(track)
					target_task.add_track(track)
					
					true
				end
				
				# Select Track by Time Range and/or Status.
				# 
				# Options:
				# 
				# - `:from`, `:to` limit the begin and end datetimes to a specific range.
				# - `:status` filter Tracks by Short Status.
				# 
				# Fixed Start and End (`from != nil && to != nil`)
				# 
				# ```
				# Selected Range           |----------|
				# Track A              +-----------------+
				# Track B                 +------+
				# Track C                      +------------+
				# Track D                       +----+
				# Track E            +---+
				# Track F                                 +---+
				# ```
				# 
				# * Track A is bigger then the Options range. Take it.
				# * Track B ends in the Options range. Take it.
				# * Track C starts in the Options range. Take it.
				# * Track D starts and ends within the Options range. Definitely take this.
				# * Track E is out-of-score. Ignore it.
				# * Track F is out-of-score. Ignore it.
				#
				# ---
				#
				# Open End (`to == nil`)  
				# Take all except Track E.
				# 
				# ```
				# Selected Range           |---------->
				# Track A              +-----------------+
				# Track B                 +------+
				# Track C                      +------------+
				# Track D                       +----+
				# Track E            +---+
				# Track F                                 +---+
				# ```
				#
				# ---
				#
				# Open Start (`from == nil`)  
				# Take all except Track F.
				# 
				# ```
				# Selected Range           <----------|
				# Track A              +-----------------+
				# Track B                 +------+
				# Track C                      +------------+
				# Track D                       +----+
				# Track E            +---+
				# Track F                                 +---+
				# ```
				def tracks(options = {})
					options ||= {}
					options[:from] ||= nil
					options[:to] ||= nil
					options[:status] ||= nil
					unless options.has_key?(:sort)
						options[:sort] = true
					end
					
					# Local variables.
					from = options[:from]
					to = options[:to]
					
					if options[:status]
						case options[:status]
						when String
							status = [options[:status]]
						when Array
							status = options[:status]
						else
							raise TaskError, "Status wrong type #{options[:status].class}."
						end
					else
						status = nil
					end
					
					if from && to && from > to
						raise TaskError, 'From cannot be bigger than To.'
					end
					
					filtered_tracks = Hash.new
					if from.nil? && to.nil?
						# Take all Tracks.
						filtered_tracks = @tracks
					elsif !from.nil? && to.nil?
						# puts "open end"
						# Open End (to == nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt <  from && edt >  from || # Track A, B
							bdt >= from && edt >= from    # Track C, D, F
						}
					elsif from.nil? && !to.nil?
						# Open Start (from == nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt <  to && edt <= to || # Track B, D, E
							bdt <  to && edt >  to    # Track A, C
						}
					elsif !from.nil? && !to.nil?
						# Fixed Start and End (from != nil && to != nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt >= from && edt <= to ||               # Track D
							bdt <  from && edt >  to ||               # Track A
							bdt <  from && edt <= to && edt > from || # Track B
							bdt >= from && edt >  to && bdt < to      # Track C
						}
					else
						raise 'Should never happen, bug shit happens.'
					end
					
					if status
						filtered_tracks.select!{ |track_id, track|
							status.include?(track.status.short_status)
						}
					end
					
					if options[:sort]
						#pp filtered_tracks # @TODO remove pp
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
				
				# Uses `tracks()` with `options` to filter.
				# 
				# Options:
				# 
				# - `:from`
				def begin_datetime(options = {})
					options ||= {}
					options[:from] ||= nil
					
					# Cache
					# if @begin_datetime
					# 	return @begin_datetime
					# end
					# Cannot use this cache because of :from :to range limitation.
					# It needs always to be direct from child Tracks, because the
					# cache does not know when the begin and end datetimes of the
					# child Tracks change.
					
					# Do not sort. We only need to sort the tracks
					# by begin_datetime and take the first.
					options[:sort] = false
					
					first_track = tracks(options)
						.select{ |track_id, track| track.begin_datetime } # filter nil
						.sort_by{ |track_id, track| track.begin_datetime }
						.to_h # sort_by makes [[]]
						.values # no keys to take the first
						.first
					
					if first_track
						bdt = first_track.begin_datetime(options)
					end
					
					if options[:from] && bdt && options[:from] > bdt
						bdt = options[:from]
					end
					
					bdt
				end
				
				# Options:
				# 
				# - `:format`
				def begin_datetime_s(options = {})
					options ||= {}
					options[:format] ||= HUMAN_DATETIME_FOMRAT
					
					bdt = begin_datetime(options)
					if bdt
						bdt.strftime(options[:format])
					end
				end
				
				# Uses `tracks()` with `options` to filter.
				# 
				# Options:
				# 
				# - `:to`
				def end_datetime(options = {})
					options ||= {}
					options[:to] ||= nil
					
					# Cache
					# if @end_datetime
					# 	return @end_datetime
					# end
					# Cannot use this cache because of :from :to range limitation.
					# It needs always to be direct from child Tracks, because the
					# cache does not know when the begin and end datetimes of the
					# child Tracks change.
					
					# Do not sort. We only need to sort the tracks
					# by end_datetime and take the last.
					options[:sort] = false
					
					last_track = tracks(options)
						.select{ |track_id, track| track.end_datetime } # filter nil
						.sort_by{ |track_id, track| track.end_datetime }
						.to_h # sort_by makes [[]]
						.values # no keys to take the last
						.last
					
					if last_track
						edt = last_track.end_datetime(options)
					end
					
					if options[:to] && edt && options[:to] < edt
						edt = options[:to]
					end
					
					edt
				end
				
				# Options:
				# 
				# - `:format`
				def end_datetime_s(options = {})
					options ||= {}
					options[:format] ||= HUMAN_DATETIME_FOMRAT
					
					edt = end_datetime(options)
					if edt
						edt.strftime(options[:format])
					end
				end
				
				# BasicModel Hook
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
				
				# BasicModel Hook
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
					# puts "#{short_id} Task start"
					
					# Track Options
					options ||= {}
					options[:track_id] ||= nil
					
					# Used by Push.
					options[:no_stop] ||= false
					
					unless options[:no_stop]
						# End current Track before starting a new one.
						# Leave options empty here for stop().
						stop
					end
					
					if options[:track_id]
						# puts "find_track_by_id #{options[:track_id]}"
						found_track = find_track_by_id(options[:track_id])
						if found_track
							# puts "clone this track: #{found_track.short_id}" # @TODO remove
							
							@current_track = found_track.dup
							# puts "cloned track: #{@current_track.short_id}"
						else
							raise TrackError, "No Track found for Track ID '#{options[:track_id]}'."
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
						# puts "#{short_id} Task stop"
						
						@current_track.stop(options)
						
						# Reset current Track variable.
						@current_track = nil
						
						# Mark Task as changed.
						changed
					end
					
					nil
				end
				
				# Pauses a current running Track.
				def pause(options = {})
					options ||= {}
					
					if @current_track
						# puts "#{short_id} Task pause"
						
						@current_track.stop(options)
						
						# Mark Task as changed.
						changed
						
						@current_track
					end
				end
				
				# Continues the current Track.
				# Only if it isn't already running.
				def continue(options = {})
					options ||= {}
					options[:track] ||= nil
					
					# puts "continue" # @TODO remove
					
					if @current_track
						if @current_track.stopped?
							# puts "Task continue: #{@current_track.short_id}" # @TODO remove
							
							# Duplicate and start.
							@current_track = @current_track.dup
							@current_track.start(options)
							
							# puts "Task continue clone: #{@current_track.short_id}" # @TODO remove
							
							add_track(@current_track)
						else
							raise TrackError, "Cannot continue Track #{@current_track.short_id}: already running."
						end
					else
						#raise NotImplementedError
						
						unless options[:track]
							raise TrackError, 'Track not set.'
						end
						
						# puts "continue clone track: #{options[:track].id}" # @TODO remove
						
						# Duplicate and start.
						@current_track = options[:track].dup
						@current_track.start(options)
						# puts "clone started: #{@current_track.id}" # @TODO remove
						
						add_track(@current_track)
					end
					
					@current_track
				end
				
				def duration(options = {})
					options ||= {}
					
					duration = Duration.new
					@tracks.each do |track_id, track|
						duration += track.duration(options)
						
						#puts "track #{track.short_id} #{duration}" # @TODO remove
					end
					duration
				end
				
				def status
					stati = @tracks.map{ |track_id, track| track.status.short_status }.to_set
					
					if @tracks.count == 0
						status = '-'
					elsif stati.include?('R')
						status = 'R'
					elsif stati.include?('S')
						status = 'S'
					else
						status = 'U'
					end
					
					Status.new(status)
				end
				
				# Find a Track by ID even if the ID is not 40 characters long.
				# When the ID is 40 characters long @tracks[id] is faster. ;)
				def find_track_by_id(track_id)
					track_id_len = track_id.length
					
					if track_id_len < 40
						found_track_id = nil
						@tracks.keys.each do |key|
							#puts "find_track_by_id: #{track_id} #{key}"
							
							if track_id == key[0, track_id_len]
								if found_track_id
									raise TrackError, "Track ID '#{track_id}' is not a unique identifier."
								else
									found_track_id = key
									#puts "find_track_by_id found track: #{found_track_id}"
									
									# Do not break the loop here.
									# Iterate all keys to make sure the ID is unique.
								end
							end
						end
						track_id = found_track_id
					end
					
					@tracks[track_id]
				end
				
				def eql?(task)
					unless task.is_a?(Task)
						raise StackError, "task variable must be a Task instance. #{task.class} given."
					end
					
					self.id == task.id
				end
				
				def to_s
					"Task_#{short_id}"
				end
				
				def inspect
					"#<Task_#{short_id} tracks=#{@tracks.count}>"
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
					
					# Search a Task in a base path for a Track by ID.
					# If found a file load it into a Task instance.
					def load_task_from_file_with_id(base_path, task_id)
						task_file_path = BasicModel.find_file_by_id(base_path, task_id)
						if task_file_path
							load_task_from_file(task_file_path)
						end
					end
					
					# Create a new Task using a Hash.
					# 
					# Options:
					# 
					# - `:name` (String)
					# - `:description` (String)
					def create_task_from_hash(hash)
						task = Task.new
						task.name = hash[:name] # || hash['name']
						task.description = hash[:description] # || hash['description']
						task
					end
					
				end
				
			end # class Task
			
		end # module Model
	end # module Timr
end #module TheFox
