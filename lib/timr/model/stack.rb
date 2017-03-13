
module TheFox
	module Timr
		
		# The Stack holds one or more Tracks.
		# Only one Track can run at a time.
		# If you push a new Track on the Stack the underlying running
		# will be paused.
		class Stack < Model
			
			attr_accessor :timr
			# attr_accessor :tasks_path
			attr_reader :tracks
			
			def initialize
				super()
				
				@timr = nil
				# @tasks_path = nil
				
				# Data
				@tracks = Array.new
			end
			
			def current_track
				@tracks.last
			end
			
			def start(track)
				stop
				
				@tracks = Array.new
				@tracks << track
				
				# Mark Stack as changed.
				changed
			end
			
			def stop
				@tracks.pop
				
				# Mark Stack as changed.
				changed
			end
			
			# def pause
			# end
			
			# def continue
			# end
			
			def push(track)
				@tracks << track
			end
			
			def pop
				@tracks.pop
			end
			
			def pre_save_to_file
				# Tracks
				@data = @tracks.map{ |track| [track.task.id, track.id] }
				
				super()
			end
			
			def post_load_from_file
				unless @timr
					raise 'Stack: @timr variable is not set.'
				end
				
				# puts "#{self.class} post_load_from_file"
				# puts "#{self.class} data: '#{@data}'"
				
				@tracks = @data.map{ |ids|
					puts "load from ids: #{ids}"
					
					task_id, track_id = ids
					# puts "load   task #{task_id}"
					# puts "      track #{track_id}"
					# puts
					
					task = @timr.get_task_by_id(task_id)
					if task
						track = task.find_track_by_id(track_id)
					# else
					# 	puts "no task found"
					end
				}.select{ |track|
					!track.nil?
				}
				
				puts "track loaded: #{@tracks.count}"
			end
			
			def to_s
				"Stack"
			end
			
			def inspect
				"#<Stack tracks=#{@tracks.count} current=#{@current_track.short_id}>"
			end
			
			# All methods in this block are static.
			# class << self
				
			# 	def load_stack_from_file(path)
			# 		stack = Stack.new
			# 		stack.load_from_file(path)
			# 		stack
			# 	end
				
			# end
			
		end # class Task
		
	end # module Timr
end #module TheFox
