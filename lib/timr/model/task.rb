
module TheFox
	module Timr
		module Model
			
			class Task < BasicModel
				
				include TheFox::Timr::Error
				
				attr_reader :foreign_id
				attr_reader :description
				attr_reader :current_track
				attr_reader :hourly_rate
				attr_reader :has_flat_rate
				
				def initialize
					super()
					
					# Meta
					@foreign_id = nil # --id
					@name = nil
					@description = nil
					@current_track = nil
					@estimation = nil
					@hourly_rate = nil
					@has_flat_rate = false
					
					# Data
					@tracks = Hash.new
				end
				
				def foreign_id=(foreign_id)
					@foreign_id = foreign_id
					
					# Mark Task as changed.
					changed
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
				
				# Get name or `---` if name is not set.
				def name_s(max_length = nil)
					s = name(max_length)
					if s.nil?
						'---'
					else
						s
					end
				end
				
				# Set description.
				def description=(description)
					@description = description
					
					# Mark Task as changed.
					changed
				end
				
				# Add a Track.
				# @TODO unit test
				def add_track(track, set_as_current_track = false)
					track.task = self
					
					@tracks[track.id] = track
					
					if set_as_current_track
						@current_track = track
					end
					
					# Mark Task as changed.
					changed
				end
				
				# Remove a Track.
				def remove_track(track)
					track.task = nil
					
					if @tracks.delete(track.id)
						# Mark Task as changed.
						changed
					else
						# Track is not assiged to this Task.
						false
					end
				end
				
				# Move a Track to another Task.
				def move_track(track, target_task)
					if eql?(target_task)
						return false
					end
					
					unless remove_track(track)
						return false
					end
					
					set_as_current_track = false
					if @current_track && @current_track.eql?(track)
						@current_track = nil
						set_as_current_track = true
					end
					
					target_task.add_track(track, set_as_current_track)
					
					true
				end
				
				# Select Track by Time Range and/or Status.
				# 
				# Options:
				# 
				# - `:from`, `:to` limit the begin and end datetimes to a specific range.
				# - `:status` filter Tracks by Short Status.
				# - `:billed` filter Tracks by is_billed flag.
				# 	- `true` filter billed Tracks.
				# 	- `false` filter unbilled Tracks.
				# 	- `nil` filter off.
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
				def tracks(options = Hash.new)
					from_opt = options.fetch(:from, nil)
					to_opt = options.fetch(:to, nil)
					status_opt = options.fetch(:status, nil)
					sort_opt = options.fetch(:sort, true)
					billed_opt = options.fetch(:billed, nil)
					
					if status_opt
						case status_opt
						when String
							status_opt = [status_opt]
						when Array
							# OK
						else
							raise TaskError, ":status needs to be an instance of String or Array, #{status_opt.class} given."
						end
					end
					
					if from_opt && to_opt && from_opt > to_opt
						raise TaskError, 'From cannot be bigger than To.'
					end
					
					filtered_tracks = Hash.new
					if from_opt.nil? && to_opt.nil?
						# Take all Tracks.
						filtered_tracks = @tracks.select{ |track_id, track|
							# Filter Tracks with no Begin DateTime.
							# This can happen when 'timr track add' without any DateTime.
							!track.begin_datetime.nil?
						}
					elsif !from_opt.nil? && to_opt.nil?
						# Open End (to_opt == nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt && (
								bdt <  from_opt && edt >  from_opt || # Track A, B
								bdt >= from_opt && edt >= from_opt    # Track C, D, F
							)
						}
					elsif from_opt.nil? && !to_opt.nil?
						# Open Start (from_opt == nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt && (
								bdt <  to_opt && edt <= to_opt || # Track B, D, E
								bdt <  to_opt && edt >  to_opt    # Track A, C
							)
						}
					elsif !from_opt.nil? && !to_opt.nil?
						# Fixed Start and End (from_opt != nil && to_opt != nil)
						filtered_tracks = @tracks.select{ |track_id, track|
							bdt = track.begin_datetime
							edt = track.end_datetime || Time.now
							
							bdt && (
								bdt >= from_opt && edt <= to_opt ||               # Track D
								bdt <  from_opt && edt >  to_opt ||               # Track A
								bdt <  from_opt && edt <= to_opt && edt > from_opt || # Track B
								bdt >= from_opt && edt >  to_opt && bdt < to_opt      # Track C
							)
						}
					else
						raise ThisShouldNeverHappenError, 'Should never happen, bug shit happens.'
					end
					
					if status_opt
						filtered_tracks.select!{ |track_id, track|
							status_opt.include?(track.status.short_status)
						}
					end
					
					unless billed_opt.nil?
						if billed_opt
							filtered_tracks.select!{ |track_id, track|
								track.is_billed
							}
						else
							filtered_tracks.select!{ |track_id, track|
								!track.is_billed
							}
						end
					end
					
					if sort_opt
						filtered_tracks.sort{ |t1, t2|
							t1 = t1.last
							t2 = t2.last
							
							cmp1 = t1.begin_datetime <=> t2.begin_datetime
							if cmp1.nil? || cmp1 == 0
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
				def begin_datetime(options = Hash.new)
					from_opt = options.fetch(:from, nil)
					
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
					
					if from_opt && bdt && from_opt > bdt
						bdt = from_opt
					end
					
					bdt
				end
				
				# Options:
				# 
				# - `:format`
				def begin_datetime_s(options = Hash.new)
					format_opt = options.fetch(:format, HUMAN_DATETIME_FOMRAT)
					
					bdt = begin_datetime(options)
					if bdt
						bdt.strftime(format_opt)
					else
						'---'
					end
				end
				
				# Uses `tracks()` with `options` to filter.
				# 
				# Options:
				# 
				# - `:to`
				def end_datetime(options = Hash.new)
					to_opt = options.fetch(:to, nil)
					
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
					
					if to_opt && edt && to_opt < edt
						edt = to_opt
					end
					
					edt
				end
				
				# Options:
				# 
				# - `:format`
				def end_datetime_s(options = Hash.new)
					format_opt = options.fetch(:format, HUMAN_DATETIME_FOMRAT)
					
					edt = end_datetime(options)
					if edt
						edt.strftime(format_opt)
					else
						'---'
					end
				end
				
				# Set estimation.
				# 
				# Either using a Duration instance, Integer or a String like `2h 30m`.
				# Estimation is parsed by [chronic_duration](https://github.com/henrypoydar/chronic_duration).
				# 
				# Examples:
				# 
				# - `-e 2:10:5`  
				#   Sets Estimation to 2h 10m 5s.
				# 	
				# - `-e '2h 10m 5s'`  
				#   Sets Estimation to 2h 10m 5s.
				#
				# Use `+` or `-` to calculate with Estimation Times:
				# 
				# - `-e '-45m'`  
				#   Subtracts 45 minutes from the original Estimation.
				# - `-e '+1h 30m'`  
				#   Adds 1 hour 30 minutes to the original Estimation.
				# 
				# See [chronic_duration](https://github.com/henrypoydar/chronic_duration) for more examples.
				def estimation=(estimation)
					case estimation
					when String
						# Cannot use estimation.strip! because frozen.
						estimation = estimation.strip
						
						if estimation[0] == '+'
							estimation = estimation[1..-1]
							@estimation += Duration.parse(estimation)
						elsif estimation[0] == '-'
							estimation = estimation[1..-1]
							@estimation -= Duration.parse(estimation)
						else
							@estimation = Duration.parse(estimation)
						end
					when Integer
						@estimation = Duration.new(estimation)
					when Duration
						@estimation = estimation
					when nil
						@estimation = estimation
					else
						raise TaskError, "estimation needs to be an instance of String, Integer, Duration or nil, #{estimation.class} given."
					end
					
					# Mark Task as changed.
					changed
				end
				
				# Get estimation.
				def estimation
					@estimation
				end
				
				# Get estimation as String.
				def estimation_s
					if @estimation
						@estimation.to_human
					else
						'---'
					end
				end
				
				# Set hourly_rate.
				def hourly_rate=(new_hourly_rate)
					if new_hourly_rate.nil?
						@hourly_rate = nil
					else
						@hourly_rate = new_hourly_rate.to_f
					end
					
					# Mark Task as changed.
					changed
				end
				
				# Set has_flat_rate.
				def has_flat_rate=(has_flat_rate)
					@has_flat_rate = has_flat_rate
					
					# Mark Task as changed.
					changed
				end
				
				# Get the actual consumed budge.
				def consumed_budge
					if @hourly_rate
						duration.to_i.to_f / 3600.0 * @hourly_rate
					else
						0.0
					end
				end
				
				# Calculate the budge based on estimation.
				def estimated_budge
					if @hourly_rate
						estimation.to_i.to_f / 3600.0 * @hourly_rate
					else
						0.0
					end
				end
				
				# Calculates the budge loss when a Flat Rate is used and the consumed duration is greater than the estimation.
				def loss_budge
					if @has_flat_rate && @hourly_rate
						if duration > estimation
							(duration - estimation).to_i.to_f / 3600.0 * @hourly_rate
						else
							0.0
						end
					else
						0.0
					end
				end
				
				# Start a new Track by given `options`.
				# 
				# Options:
				# 
				# - `:foreign_id` (String)
				# - `:track_id` (String)
				# - `:no_stop` (Boolean)
				def start(options = Hash.new)
					foreign_id_opt = options.fetch(:foreign_id, nil)
					track_id_opt = options.fetch(:track_id, nil)
					
					# Used by Push.
					no_stop_opt = options.fetch(:no_stop, false)
					
					unless no_stop_opt
						# End current Track before starting a new one.
						# Leave options empty here for stop().
						stop
					end
					
					if foreign_id_opt && @foreign_id.nil?
						@foreign_id = foreign_id_opt
					end
					
					if track_id_opt
						found_track = find_track_by_id(track_id_opt)
						if found_track
							
							@current_track = found_track.dup
						else
							raise TrackError, "No Track found for Track ID '#{track_id_opt}'."
						end
					else
						@current_track = Track.new
						@current_track.task = self
					end
					
					@tracks[@current_track.id] = @current_track
					
					# Mark Task as changed.
					changed
					
					@current_track.start(options)
					@current_track
				end
				
				# Stops a current running Track.
				def stop(options = Hash.new)
					if @current_track
						@current_track.stop(options)
						
						# Reset current Track variable.
						@current_track = nil
						
						# Mark Task as changed.
						changed
					end
					
					nil
				end
				
				# Pauses a current running Track.
				def pause(options = Hash.new)
					if @current_track
						@current_track.stop(options)
						
						# Mark Task as changed.
						changed
						
						@current_track
					end
				end
				
				# Continues the current Track.
				# Only if it isn't already running.
				def continue(options = Hash.new)
					track_opt = options.fetch(:track, nil)
					
					if @current_track
						if @current_track.stopped?
							
							# Duplicate and start.
							@current_track = @current_track.dup
							@current_track.start(options)
							
							
							add_track(@current_track)
						else
							raise TrackError, "Cannot continue Track #{@current_track.short_id}: already running."
						end
					else
						unless track_opt
							raise TaskError, 'No Track given.'
						end
						
						# Duplicate and start.
						@current_track = track_opt.dup
						@current_track.start(options)
						
						add_track(@current_track)
					end
					
					@current_track
				end
				
				# Consumed duration.
				# 
				# Options:
				# 
				# - `:billed`
				def duration(options = Hash.new)
					
					billed_opt = options.fetch(:billed, nil)
					
					duration = Duration.new
					@tracks.each do |track_id, track|
						if billed_opt.nil? || (billed_opt && track.is_billed) || (!billed_opt && !track.is_billed)
							duration += track.duration(options)
						end
					end
					duration
				end
				
				# Alias for `duration` method.
				# 
				# Options:
				# 
				# - `:billed` (Boolean)
				def billed_duration(options = Hash.new)
					duration(options.merge({:billed => true}))
				end
				
				# Alias for `duration` method.
				# 
				# Options:
				# 
				# - `:billed` (Boolean)
				def unbilled_duration(options = Hash.new)
					duration(options.merge({:billed => false}))
				end
				
				# Get the remaining Time of estimation.
				# 
				# Returns a Duration instance.
				def remaining_time
					if @estimation
						estimation - duration
					end
				end
				
				# Get the remaining Time as Human String.
				# 
				# - Like `2h 30m`.
				# - Or `---` when `@estimation` is `nil`.
				def remaining_time_s
					rmt = remaining_time
					if rmt
						rmt.to_human
					else
						'---'
					end
				end
				
				# Get the remaining Time as percent.
				def remaining_time_percent
					rmt = remaining_time
					if rmt && @estimation
						(rmt.to_i.to_f / @estimation.to_i.to_f) * 100.0
					end
				end
				
				# Get the remaining Time Percent as String.
				def remaining_time_percent_s
					rmtp = remaining_time_percent
					if rmtp
						'%.1f %%' % [rmtp]
					else
						'---'
					end
				end
				
				# Get Task status as Status instance.
				def status
					stati = @tracks.map{ |track_id, track| track.status.short_status }.to_set
					
					if @tracks.count == 0
						status = ?-
					elsif stati.include?(?R)
						status = ?R
					elsif stati.include?(?S)
						status = ?S
					else
						status = ?U
					end
					
					Status.new(status)
				end
				
				# Set is_billed.
				def is_billed=(is_billed)
					@tracks.each do |track_id, track|
						track.is_billed = is_billed
					end
				end
				
				# Find a Track by ID even if the ID is not 40 characters long.
				# When the ID is 40 characters long `@tracks[id]` is faster. ;)
				def find_track_by_id(track_id)
					track_id_len = track_id.length
					
					# puts "search track id '#{track_id}'"
					
					if track_id_len < 40
						found_track_id = nil
						@tracks.keys.each do |key|
							if track_id == key[0, track_id_len]
								if found_track_id
									raise TrackError, "Track ID '#{track_id}' is not a unique identifier."
								else
									found_track_id = key
									
									# Do not break the loop here.
									# Iterate all keys to make sure the ID is unique.
								end
							end
						end
						track_id = found_track_id
					end
					
					@tracks[track_id]
				end
				
				# Are two Tasks equal?
				# 
				# Uses ID for comparision.
				#
				# @TODO unit test
				def eql?(task)
					unless task.is_a?(Task)
						raise TaskError, "task variable must be a Task instance. #{task.class} given."
					end
					
					self.id == task.id
				end
				
				# To String
				def to_s
					"Task_#{short_id}"
				end
				
				# Used to print informations to STDOUT.
				def to_compact_str
					to_compact_array.join("\n")
				end
				
				# Used to print informations to STDOUT.
				def to_compact_array
					to_ax = Array.new
					if self.foreign_id
						to_ax << 'Task: %s %s %s' % [self.short_id, self.foreign_id, self.name]
					else
						to_ax << 'Task: %s %s' % [self.short_id, self.name]
					end
					if self.description
						to_ax << '  Description: %s' % [self.description]
					end
					if self.estimation
						to_ax << '  Estimation: %s' % [self.estimation.to_human]
					end
					to_ax << '  File path: %s' % [self.file_path]
					to_ax
				end
				
				# Used to print informations to STDOUT.
				def to_detailed_str
					to_detailed_array.join("\n")
				end
				
				# Used to print informations to STDOUT.
				def to_detailed_array
					to_ax = Array.new
					to_ax << 'Task: %s' % [self.short_id]
					to_ax << '  ID: %s' % [self.id]
					if self.foreign_id
						to_ax << '  Foreign ID: %s' % [self.foreign_id]
					end
					to_ax << '  Name: %s' % [self.name]
					
					if self.description
						to_ax << '  Description: %s' % [self.description]
					end
					
					# Duration
					duration_human = self.duration.to_human
					to_ax << '  Duration:          %s' % [duration_human]
					
					duration_man_days = self.duration.to_man_days
					if duration_human != duration_man_days
						to_ax << '  Man Unit:          %s' % [duration_man_days]
					end
					
					# Billed Duration
					billed_duration_human = self.billed_duration.to_human
					to_ax << '  Billed Duration:   %s' % [billed_duration_human]
					
					# Unbilled Duration
					unbilled_duration_human = self.unbilled_duration.to_human
					to_ax << '  Unbilled Duration: %s' % [unbilled_duration_human]
					
					if self.estimation
						to_ax << '  Estimation:     %s' % [self.estimation.to_human]
						
						to_ax << '  Time Remaining: %s (%s)' % [self.remaining_time_s, self.remaining_time_percent_s]
						
						bar_options = {
							:total => self.estimation.to_i,
							:progress => self.duration.to_i,
							:length => 50,
							:progress_mark => '#',
							:remainder_mark => '-',
						}
						bar = ProgressBar.new(bar_options)
						
						to_ax << '                  |%s|' % [bar.render]
					end
					
					if self.hourly_rate
						to_ax << '  Hourly Rate:     %.2f' % [self.hourly_rate]
						to_ax << '  Flat Rate:       %s' % [@has_flat_rate ? 'Yes' : 'No']
						
						to_ax << '  Consumed Budge:  %.2f' % [self.consumed_budge]
						
						if self.estimation
							to_ax << '  Estimated Budge: %.2f' % [self.estimated_budge]
						end
						
						if @has_flat_rate
							to_ax << '  Loss Budge:      %.2f' % [self.loss_budge]
						end
					end
					
					tracks = self.tracks
					first_track = tracks
						.select{ |track_id, track| track.begin_datetime }
						.sort_by{ |track_id, track| track.begin_datetime }
						.to_h
						.values
						.first
					if first_track
						to_ax << '  Begin Track: %s  %s' % [first_track.short_id, first_track.begin_datetime_s]
					end
					
					last_track = tracks
						.select{ |track_id, track| track.end_datetime }
						.sort_by{ |track_id, track| track.end_datetime }
						.to_h
						.values
						.last
					if last_track
						to_ax << '  End   Track: %s  %s' % [last_track.short_id, last_track.end_datetime_s]
					end
					
					status = self.status.colorized
					to_ax << '  Status: %s' % [status]
					
					if @current_track
						to_ax << '  Current Track: %s %s' % [@current_track.short_id, @current_track.title]
					end
					
					tracks_count = tracks.count
					to_ax << '  Tracks:          %d' % [tracks_count]
					
					billed_tracks_count = tracks({:billed => true}).count
					to_ax << '  Billed Tracks:   %d' % [billed_tracks_count]
					
					unbilled_tracks_count = tracks({:billed => false}).count
					to_ax << '  Unbilled Tracks: %d' % [unbilled_tracks_count]
					
					if tracks_count > 0 && @tracks_opt # --tracks
						to_ax << '  Track IDs: %s' % [tracks.map{ |track_id, track| track.short_id }.join(' ')]
					end
					
					to_ax << '  File path: %s' % [self.file_path]
					
					to_ax
				end
				
				def inspect
					"#<Task_#{short_id} tracks=#{@tracks.count}>"
				end
				
				# All methods in this block are static.
				class << self
					
					# Load a Task from a file into a Task instance.
					def load_task_from_file(path)
						task = Task.new
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
					# - `:foreign_id` (String)
					# - `:name` (String)
					# - `:description` (String)
					# - `:estimation` (String|Integer|Duration)
					# - `:hourly_rate` (Integer)
					def create_task_from_hash(options)
						task = Task.new
						# task.foreign_id = options.fetch(:foreign_id, nil)
						task.name = options.fetch(:name, nil)
						task.description = options.fetch(:description, nil)
						task.estimation = options.fetch(:estimation, nil)
						task.hourly_rate = options.fetch(:hourly_rate, nil)
						task.has_flat_rate = options.fetch(:has_flat_rate, false)
						task
					end
					
				end
				
				private
				
				# BasicModel Hook
				def pre_save_to_file
					# Meta
					@meta['foreign_id'] = @foreign_id
					@meta['name'] = @name
					@meta['description'] = @description
					
					@meta['current_track_id'] = nil
					if @current_track
						@meta['current_track_id'] = @current_track.id
					end
					
					if @estimation
						@meta['estimation'] = @estimation.to_i
					end
					if @hourly_rate
						@meta['hourly_rate'] = @hourly_rate.to_f
					else
						@meta['hourly_rate'] = nil
					end
					if @has_flat_rate
						@meta['has_flat_rate'] = @has_flat_rate
					else
						@meta['has_flat_rate'] = false
					end
					
					# Tracks
					@data = @tracks.map{ |track_id, track|
						[track_id, track.to_h]
					}.to_h
					
					super()
				end
				
				# BasicModel Hook
				def post_load_from_file
					@tracks = @data.map{ |track_id, track_h|
						track = Track.create_track_from_hash(track_h)
						track.task = self
						[track_id, track]
					}.to_h
					
					current_track_id = @meta['current_track_id']
					if current_track_id
						@current_track = @tracks[current_track_id]
					end
					
					@foreign_id = @meta['foreign_id']
					@name = @meta['name']
					@description = @meta['description']
					
					if @meta['estimation']
						@estimation = Duration.new(@meta['estimation'])
					end
					if @meta['hourly_rate']
						@hourly_rate = @meta['hourly_rate'].to_f
					end
					if @meta['has_flat_rate']
						@has_flat_rate = @meta['has_flat_rate']
					end
				end
				
			end # class Task
			
		end # module Model
	end # module Timr
end #module TheFox
