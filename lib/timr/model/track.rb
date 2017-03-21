
require 'time'

module TheFox
	module Timr
		
		class Track < Model
			
			# Parent Task instance
			attr_accessor :task
			
			# Track Message. What have you done?
			attr_accessor :message
			
			# Is this even in use? ;D
			attr_accessor :paused
			
			def initialize
				super()
				
				@task = nil
				
				@begin_datetime = nil
				@end_datetime = nil
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
					raise ArgumentError, "begin_datetime needs to be a String or Time, #{begin_datetime.class} given."
				end
				
				@begin_datetime = begin_datetime
			end
			
			# Get begin_datetime.
			# 
			# Options:
			# 
			# - `:from`
			def begin_datetime(options = {})
				options ||= {}
				options[:from] ||= nil
				
				if @begin_datetime
					if options[:from] && options[:from] > @begin_datetime
						bdt = options[:from]
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
			# - `:format`
			def begin_datetime_s(options = {})
				options ||= {}
				options[:format] ||= HUMAN_DATETIME_FOMRAT
				
				begin_datetime(options).strftime(options[:format])
			end
			
			# Set end_datetime.
			def end_datetime=(end_datetime)
				case end_datetime
				when String
					end_datetime = Time.parse(end_datetime)
				when Time
					# OK
				else
					raise ArgumentError, "end_datetime needs to be a String or Time, #{end_datetime.class} given."
				end
				
				@end_datetime = end_datetime
			end
			
			# Get end_datetime.
			# 
			# Options:
			# 
			# - `:to`
			def end_datetime(options = {})
				options ||= {}
				options[:to] ||= nil
				
				if @end_datetime
					if options[:to] && options[:to] < @end_datetime
						edt = options[:to]
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
			# - `:format`
			def end_datetime_s(options = {})
				options ||= {}
				options[:format] ||= HUMAN_DATETIME_FOMRAT
				
				end_datetime(options).strftime(options[:format])
			end
			
			def start(options = {})
				options ||= {}
				options[:message] ||= nil
				
				if @begin_datetime
					raise 'Cannot re-start Track. Use dup() on this instance or create a new instance by using Track.new().'
				end
				
				@begin_datetime = self.class.get_datetime_from_options(options)
				
				if options[:message]
					@message = options[:message]
				end
			end
			
			def stop(options = {})
				# puts "Track stop"
				
				options ||= {}
				options[:start_date] ||= nil
				options[:start_time] ||= nil
				options[:message] ||= nil
				options[:paused] ||= false
				
				# Set Start DateTime
				if options[:start_date] || options[:start_time]
					puts "set start date/time: #{options[:start_date]} #{options[:start_time]}"
					begin_options = {
						:date => options[:start_date],
						:time => options[:start_time],
					}
					@begin_datetime = self.class.get_datetime_from_options(begin_options)
				end
				
				# Set End DateTime
				@end_datetime = self.class.get_datetime_from_options(options)
				# puts "track end time: #{@end_datetime}"
				
				if options[:message]
					if options[:append]
						# puts "   old message: '#{@message}'"
						# puts "append message: '#{options[:message]}'"
						@message << ' ' << options[:message]
						# puts "   new message: '#{@message}'"
					else
						@message = options[:message]
					end
				end
				
				@paused = options[:paused]
				
				changed
			end
			
			# Cacluates the hours, minutes and secondes between begin and end datetime.
			# 
			# Options:
			# 
			# - `:from`, `:to` limit the begin and end datetimes to a specific range.
			def duration(options = {})
				options ||= {}
				options[:from] ||= nil
				options[:to] ||= nil
				
				if @begin_datetime
					bdt = @begin_datetime.utc
					#puts "Track duration: bdt #{bdt}"
				end
				if @end_datetime
					edt = @end_datetime.utc
				else
					edt = Time.now.utc
				end
				
				# Cut Start
				if options[:from] && bdt && options[:from] > bdt
					bdt = options[:from].utc
				end
				
				# Cut End
				if options[:to] && options[:to] < edt
					edt = options[:to].utc
				end
				
				seconds = if bdt
						(edt - bdt).to_i
					else
						0
					end
				
				Duration.new(seconds)
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
			
			def stopped?
				short_status == 'S' # stopped
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
				
				# puts "max_length: #{max_length} + 2"
				# puts "msg: #{msg.length}"
				if max_length && msg.length > max_length + 2
					msg = msg[0, max_length] << '...'
				end
				msg
			end
			
			# Title Alias
			def name(max_length = nil)
				title(max_length)
			end
			
			def changed
				super()
				
				if @task
					@task.changed
				end
			end
			
			# Alias for Task.
			# A Track cannot saved to a file. Only the whole Task.
			def save_to_file(path = nil, force = false)
				if @task
					@task.save_to_file(path, force)
				end
			end
			
			def dup
				track = Track.new
				track.task = @task
				track.message = @message.clone
				track
			end
			
			def to_s
				"Track_#{@meta['id']}"
			end
			
			def to_h
				h = {
					'id' => @meta['id'],
					'short_id' => short_id, # Not used.
					'created' => @meta['created'],
					'modified' => @meta['modified'],
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
			
			def inspect
				"#<Track #{@meta['id']}>"
			end
			
			# All methods in this block are static.
			class << self
				
				# Helper method
				def get_datetime_from_options(options = {})
					options ||= {}
					options[:date] ||= nil
					options[:time] ||= nil
					
					if options[:date] && !options[:time]
						raise ArgumentError, 'You also need to set a time when giving a date'
					end
					
					datetime_a = []
					if options[:date]
						datetime_a << options[:date]
					end
					if options[:time]
						datetime_a << options[:time]
					end
					
					if datetime_a.count > 0
						datetime_s = datetime_a.join(' ')
						Time.parse(datetime_s).utc
					else
						Time.now.utc
					end
					
					
					
					# date = DateTimeHelper.convert_date(options[:date])
					# time = DateTimeHelper.convert_time(options[:time])
					
					# dy = date.year
					# dm = date.month
					# dd = date.day
					# th = time.hour
					# tm = time.min
					# ts = time.sec
					# tz = 0 # UTC (Timezone)
					
					# Time.new(dy, dm, dd, th, tm, ts, tz)
				end
				
				# Create a new Track instance from a Hash.
				def create_track_from_hash(hash)
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
					if hash['message']
						track.message = hash['message']
					end
					if hash['begin_datetime']
						track.begin_datetime = hash['begin_datetime']
					end
					if hash['end_datetime']
						track.end_datetime = hash['end_datetime']
					end
					track.changed = false
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
								raise "Track ID '#{track_id}' is not a unique identifier."
							else
								found_track = tmp_track
							end
						end
					end
					
					found_track
				end
				
			end
			
		end # class Track
		
	end # module Timr
end #module TheFox
