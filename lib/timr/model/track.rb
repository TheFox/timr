
require 'time'

module TheFox
	module Timr
		module Model
			
			class Track < BasicModel
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Parent Task instance
				attr_accessor :task
				
				# Track Message. What have you done?
				attr_reader :message
				
				# Is this even in use? ;D
				attr_accessor :paused
				
				attr_reader :is_billed
				
				def initialize
					super()
					
					@task = nil
					
					@begin_datetime = nil
					@end_datetime = nil
					@is_billed = false
					@message = nil
					@paused = false
				end
				
				# Set begin_datetime.
				def begin_datetime=(begin_datetime)
					case begin_datetime
					when String
						begin_datetime = Time.parse(begin_datetime)
					when Time
						# OK
					else
						raise TrackError, "begin_datetime needs to be a String or Time, #{begin_datetime.class} given."
					end
					
					if @end_datetime && begin_datetime >= @end_datetime
						raise TrackError, 'begin_datetime must be lesser than end_datetime.'
					end
					
					@begin_datetime = begin_datetime
					
					# Mark Track as changed.
					changed
				end
				
				# Get begin_datetime.
				# 
				# Options:
				# 
				# - `:from` (Time)  
				#   See documentation about `:to` on `end_datetime()`.
				def begin_datetime(options = Hash.new)
					from_opt = options.fetch(:from, nil)
					
					if @begin_datetime
						if from_opt && from_opt > @begin_datetime
							bdt = from_opt
						else
							bdt = @begin_datetime
						end
						bdt.localtime
					end
				end
				
				# Get begin_datetime String.
				# 
				# Options:
				# 
				# - `:format` (String)
				def begin_datetime_s(options = Hash.new)
					format_opt = options.fetch(:format, HUMAN_DATETIME_FOMRAT)
					
					bdt = begin_datetime(options)
					if bdt
						bdt.strftime(format_opt)
					else
						'---'
					end
				end
				
				# Set end_datetime.
				def end_datetime=(end_datetime)
					if !@begin_datetime
						raise TrackError, 'end_datetime cannot be set until begin_datetime is set.'
					end
					
					case end_datetime
					when String
						end_datetime = Time.parse(end_datetime)
					when Time
						# OK
					else
						raise TrackError, "end_datetime needs to be a String or Time, #{end_datetime.class} given."
					end
					
					if end_datetime <= @begin_datetime
						raise TrackError, 'end_datetime must be greater than begin_datetime.'
					end
					
					@end_datetime = end_datetime
					
					# Mark Track as changed.
					changed
				end
				
				# Get end_datetime.
				# 
				# Options:
				# 
				# - `:to` (Time)  
				#   This limits `@end_datetime`. If `:to` > `@end_datetime` it returns the
				# original `@end_datetime`. Otherwise it will return `:to`. The same applies for
				# `:from` on `begin_datetime()` but just the other way round.
				def end_datetime(options = Hash.new)
					to_opt = options.fetch(:to, nil)
					
					if @end_datetime
						if to_opt && to_opt < @end_datetime
							edt = to_opt
						else
							edt = @end_datetime
						end
						edt.localtime
					end
				end
				
				# Get end_datetime String.
				# 
				# Options:
				# 
				# - `:format` (String)
				def end_datetime_s(options = Hash.new)
					format_opt = options.fetch(:format, HUMAN_DATETIME_FOMRAT)
					
					edt = end_datetime(options)
					if edt
						edt.strftime(format_opt)
					else
						'---'
					end
				end
				
				# Set message.
				def message=(message)
					@message = message
					
					# Mark Track as changed.
					changed
				end
				
				# Start this Track. A Track cannot be restarted because it's the smallest time unit.
				def start(options = Hash.new)
					message_opt = options.fetch(:message, nil)
					
					if @begin_datetime
						raise TrackError, 'Cannot restart Track. Use dup() on this instance or create a new instance by using Track.new().'
					end
					
					@begin_datetime = DateTimeHelper.get_datetime_from_options(options)
					
					if message_opt
						@message = message_opt
					end
				end
				
				# Stop this Track.
				# 
				# Options:
				# 
				# - `:start_date`
				# - `:start_time`
				# - `:end_date`, `:date`
				# - `:end_time`, `:time`
				# - `:message` (String)
				def stop(options = Hash.new)
					start_date_opt = options.fetch(:start_date, nil)
					start_time_opt = options.fetch(:start_time, nil)
					end_date_opt = options.fetch(:end_date, options.fetch(:date, nil))
					end_time_opt = options.fetch(:end_time, options.fetch(:time, nil))
					message_opt = options.fetch(:message, nil)
					# paused_opt = options.fetch(:paused, false)
					
					# Set Start DateTime
					if start_date_opt || start_time_opt
						begin_options = {
							:date => start_date_opt,
							:time => start_time_opt,
						}
						@begin_datetime = DateTimeHelper.get_datetime_from_options(begin_options)
					end
					
					# Set End DateTime
					end_options = {
						:date => end_date_opt,
						:time => end_time_opt,
					}
					@end_datetime = DateTimeHelper.get_datetime_from_options(end_options)
					
					if message_opt
						@message = message_opt
					end
					
					# @paused = paused_opt
					
					# Mark Track as changed.
					changed
				end
				
				# Cacluates the secondes between begin and end datetime and returns a new Duration instance.
				# 
				# Options:
				# 
				# - `:from` (Time), `:to` (Time)  
				#   Limit the begin and end datetimes to a specific range.
				def duration(options = Hash.new)
					from_opt = options.fetch(:from, nil)
					to_opt = options.fetch(:to, nil)
					
					if @begin_datetime
						bdt = @begin_datetime.utc
					end
					if @end_datetime
						edt = @end_datetime.utc
					else
						edt = Time.now.utc
					end
					
					# Cut Start
					if from_opt && bdt && from_opt > bdt
						bdt = from_opt.utc
					end
					
					# Cut End
					if to_opt && edt && to_opt < edt
						edt = to_opt.utc
					end
					
					seconds = 0
					if bdt && edt
						if bdt < edt
							seconds = (edt - bdt).to_i
						end
					end
					
					Duration.new(seconds)
				end
				
				# Alias method.
				def billed_duration(options = Hash.new)
					if self.is_billed
						duration(options)
					else
						Duration.new(0)
					end
				end
				
				# Alias method.
				def unbilled_duration(options = Hash.new)
					if !self.is_billed
						duration(options)
					else
						Duration.new(0)
					end
				end
				
				# When begin_datetime is `2017-01-01 01:15`  
				#  and end_datetime   is `2017-01-03 02:17`  
				# this function returns
				# 
				# ```
				# [
				# 	Date.new(2017, 1, 1),
				# 	Date.new(2017, 1, 2),
				# 	Date.new(2017, 1, 3),
				# ]
				# ```
				def days
					begin_date = @begin_datetime.to_date
					end_date = @end_datetime.to_date
					
					begin_date.upto(end_date)
				end
				
				# Evaluates the Short Status and returns a new Status instance.
				def status
					if @begin_datetime.nil?
						short_status = '-' # not started
					elsif @end_datetime.nil?
						short_status = 'R' # running
					elsif @end_datetime
						if @paused
							# It's actually stopped but with an additional flag.
							short_status = 'P' # paused
						else
							short_status = 'S' # stopped
						end
					else
						short_status = 'U' # unknown
					end
					
					Status.new(short_status)
				end
				
				# Is the Track stopped?
				def stopped?
					status.short_status == 'S' # stopped
				end
				
				# Title generated from message. If the message has multiple lines only the first
				# line will be taken to create the title.
				# 
				# `max_length` can be used to define a maximum length. Three dots `...` will be appended
				# at the end if the title is longer than `max_length`.
				def title(max_length = nil)
					unless @message
						return
					end
					
					msg = @message.split("\n\n").first.split("\n").first
					
					if max_length && msg.length > max_length + 2
						msg = msg[0, max_length] << '...'
					end
					msg
				end
				
				# Title Alias
				def name(max_length = nil)
					title(max_length)
				end
				
				# Set is_billed.
				def is_billed=(is_billed)
					@is_billed = is_billed
					
					# Mark Track as changed.
					changed
				end
				
				# When the Track is marked as changed it needs to mark the Task as changed.
				# 
				# A single Track cannot be stored to a file. Tracks are assiged to a Task and are stored to the Task file.
				def changed
					super()
					
					if @task
						@task.changed
					end
				end
				
				# Alias for Task. A Track cannot saved to a file. Only the whole Task.
				def save_to_file(path = nil, force = false)
					if @task
						@task.save_to_file(path, force)
					end
				end
				
				# Duplicate this Track using the same Message. This is used almost by every Command.  
				# Start, Continue, Push, etc.
				def dup
					track = Track.new
					track.task = @task
					track.message = @message.clone
					track
				end
				
				# Removes itself from parent Task.
				def remove
					if @task
						@task.remove_track(self)
					else
						false
					end
				end
				
				# To String
				def to_s
					"Track_#{short_id}"
				end
				
				# To Hash
				def to_h
					h = {
						'id' => @meta['id'],
						'short_id' => short_id, # Not used.
						'created' => @meta['created'],
						'modified' => @meta['modified'],
						'is_billed' => @is_billed,
						'message' => @message,
					}
					if @begin_datetime
						h['begin_datetime'] = @begin_datetime.utc.strftime(MODEL_DATETIME_FORMAT)
					end
					if @end_datetime
						h['end_datetime'] = @end_datetime.utc.strftime(MODEL_DATETIME_FORMAT)
					end
					h
				end
				
				# Used to print informations to STDOUT.
				def to_compact_str
					to_compact_array.join("\n")
				end
				
				# Used to print informations to STDOUT.
				def to_compact_array
					to_ax = Array.new
					
					if @task
						to_ax.concat(@task.to_track_array)
					end
					
					to_ax << 'Track: %s %s' % [self.short_id, self.title]
					
					# if self.title
					# 	to_ax << 'Title: %s' % [self.title]
					# end
					if self.begin_datetime
						to_ax << 'Start: %s' % [self.begin_datetime_s]
					end
					if self.end_datetime
						to_ax << 'End:   %s' % [self.end_datetime_s]
					end
					
					if self.duration && self.duration.to_i > 0
						to_ax << 'Duration: %s' % [self.duration.to_human_s]
					end
					
					to_ax << 'Status: %s' % [self.status.colorized]
					
					# if self.message
					# 	to_ax << 'Message: %s' % [self.message]
					# end
					
					to_ax
				end
				
				# Used to print informations to STDOUT.
				def to_detailed_str(options = Hash.new)
					to_detailed_array(options).join("\n")
				end
				
				# Used to print informations to STDOUT.
				# 
				# Options:
				# 
				# - `:full_id` (Boolean) Show full Task and Track IDs.
				def to_detailed_array(options = Hash.new)
					full_id_opt = options.fetch(:full_id, false) # @TODO full_id unit test
					
					to_ax = Array.new
					
					if @task
						to_ax.concat(@task.to_track_array(options))
					end
					
					if full_id_opt
						to_ax << 'Track: %s' % [self.id]
					else
						to_ax << 'Track: %s' % [self.short_id]
					end
					
					if self.begin_datetime
						to_ax << 'Start: %s' % [self.begin_datetime_s]
					end
					if self.end_datetime
						to_ax << 'End:   %s' % [self.end_datetime_s]
					end
					
					if self.duration && self.duration.to_i > 0
						duration_human = self.duration.to_human_s
						to_ax << 'Duration: %s' % [duration_human]
						
						duration_man_days = self.duration.to_man_days
						if duration_human != duration_man_days
							to_ax << 'Man Unit: %s' % [duration_man_days]
						end
					end
					
					to_ax << 'Billed: %s' % [self.is_billed ? 'Yes' : 'No']
					to_ax << 'Status: %s' % [self.status.colorized]
					
					if self.message
						to_ax << 'Message: %s' % [self.message]
					end
					
					to_ax
				end
				
				# Are two Tracks equal?
				# 
				# Uses ID for comparision.
				def eql?(track)
					unless track.is_a?(Track)
						raise TrackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					self.id == track.id
				end
				
				# Return formatted String.
				# 
				# Options:
				# 
				# - `:format`
				# 
				# Format:
				# 
				# - `%id` - ID
				# - `%sid` - Short ID
				# - `%t` - Title generated from message.
				# - `%m` - Message
				# - `%bdt` - Begin DateTime
				# - `%bd` - Begin Date
				# - `%bt` - Begin Time
				# - `%edt` - End DateTime
				# - `%ed` - End Date
				# - `%et` - End Time
				# - `%ds` - Duration Seconds
				# - `%dh` - Duration Human Format
				def formatted(options = Hash.new)
					format = options.fetch(:format, '')
					
					formatted_s = format
						.gsub('%id', self.id)
						.gsub('%sid', self.short_id)
						.gsub('%t', self.title ? self.title : '')
						.gsub('%m', self.message ? self.message : '')
						.gsub('%bdt', self.begin_datetime ? self.begin_datetime.strftime('%F %H:%M') : '')
						.gsub('%bd', self.begin_datetime ? self.begin_datetime.strftime('%F') : '')
						.gsub('%bt', self.begin_datetime ? self.begin_datetime.strftime('%H:%M') : '')
						.gsub('%edt', self.end_datetime ? self.end_datetime.strftime('%F %H:%M') : '')
						.gsub('%ed', self.end_datetime ? self.end_datetime.strftime('%F') : '')
						.gsub('%et', self.end_datetime ? self.end_datetime.strftime('%H:%M') : '')
						.gsub('%ds', self.duration.to_s)
					
					duration_human = self.duration.to_human
					if duration_human
						formatted_s.gsub!('%dh', self.duration.to_human)
					else
						formatted_s.gsub!('%dh', '')
					end
					
					task_formating_options = {
						:format => formatted_s,
						:prefix => '%T',
					}
					
					if @task
						formatted_s = @task.formatted(task_formating_options)
					else
						tmp_task = Task.new
						tmp_task.id = ''
						
						formatted_s = tmp_task.formatted(task_formating_options)
					end
					
					formatted_s
				end
				
				def inspect
					"#<Track #{short_id}>"
				end
				
				# All methods in this block are static.
				class << self
					
					# Create a new Track instance from a Hash.
					def create_track_from_hash(hash)
						unless hash.is_a?(Hash)
							raise TrackError, "hash variable must be a Hash instance. #{hash.class} given."
						end
						
						track = Track.new
						if hash['id']
							track.id = hash['id']
						end
						if hash['created']
							track.created = hash['created']
						end
						if hash['modified']
							track.modified = hash['modified']
						end
						if hash['is_billed']
							track.is_billed = hash['is_billed']
						end
						if hash['message']
							track.message = hash['message']
						end
						if hash['begin_datetime']
							track.begin_datetime = hash['begin_datetime']
						end
						if hash['end_datetime']
							track.end_datetime = hash['end_datetime']
						end
						track.has_changed = false
						track
					end
					
					# This is really bad. Do not use this.
					def find_track_by_id(base_path, track_id)
						found_track = nil
						
						# Iterate all files.
						base_path.find.each do |file|
							# Filter all directories.
							unless file.file?
								next
							end
							
							# Filter all non-yaml files.
							unless file.basename.fnmatch('*.yml')
								next
							end
							
							task = Task.load_task_from_file(file)
							tmp_track = task.find_track_by_id(track_id)
							if tmp_track
								if found_track
									raise TrackError, "Track ID '#{track_id}' is not a unique identifier."
								else
									found_track = tmp_track
									
									# Do not break the loop here.
								end
							end
						end
						
						found_track
					end
					
				end
				
			end # class Track
			
		end # module Model
	end # module Timr
end #module TheFox
