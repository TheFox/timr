
require 'time'

module TheFox
	module Timr
		
		class Track < Model
			
			attr_accessor :task
			attr_reader :begin_datetime
			attr_reader :end_datetime
			attr_accessor :message
			attr_accessor :paused
			
			def initialize
				super()
				
				@task = nil
				
				@begin_datetime = nil
				@end_datetime = nil
				@message = nil
				@paused = false
			end
			
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
			
			def begin_datetime_s(format = HUMAN_DATETIME_FOMRAT, from = nil)
				if @begin_datetime
					if from && from > @begin_datetime
						from.localtime.strftime(format)
					else
						@begin_datetime.localtime.strftime(format)
					end
				end
			end
			
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
			
			def end_datetime_s(format = HUMAN_DATETIME_FOMRAT, to = nil)
				if @end_datetime
					if to && to < @end_datetime
						to.localtime.strftime(format)
					else
						@end_datetime.localtime.strftime(format)
					end
				end
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
			
			# When begin_datetime is 2017-01-01 01:15
			#  and end_datetime   is 2017-01-03 02:17
			# this function returns
			#   [
			#   	Date.new(2017, 1, 1),
			#   	Date.new(2017, 1, 2),
			#   	Date.new(2017, 1, 3),
			#   ]
			def days
				begin_date = @begin_datetime.to_date
				end_date = @end_datetime.to_date
				
				begin_date.upto(end_date)
			end
			
			def short_status
				if @begin_datetime.nil?
					'-' # not started
				elsif @end_datetime.nil?
					'R' # running
				elsif @end_datetime
					if @paused
						# It's actually stopped but with an additional flag.
						'P' # paused
					else
						'S' # stopped
					end
				else
					'U' # unknown
				end
			end
			
			def long_status
				s = short_status
				case s
				when '-'
					'not started'
				when 'R'
					'running'
				when 'S'
					'stopped'
				when 'P'
					'paused'
				when 'U'
					'unknown'
				end
			end
			
			def stopped?
				short_status == 'S' # stopped
			end
			
			# This is the title.
			# 
			# This could be a longer description.
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
						track = task.find_track_by_id(track_id)
						if track
							return track
						end
					end
					
					nil
				end
				
			end
			
		end # class Track
		
	end # module Timr
end #module TheFox
