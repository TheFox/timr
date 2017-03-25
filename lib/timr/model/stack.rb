
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
				unless track.is_a?(Track)
					raise ArgumentError, "track variable must be a Track instance. #{track.class} given."
				end
				
				stop
				
				@tracks = Array.new
				@tracks << track
				
				# Mark Stack as changed.
				changed
			end
			
			def stop
				if @tracks.count > 0
					@tracks.pop
					
					# Mark Stack as changed.
					changed
				end
			end
			
			def push(track)
				unless track.is_a?(Track)
					raise ArgumentError, "track variable must be a Track instance. #{track.class} given."
				end
				
				@tracks << track
				
				# Mark Stack as changed.
				changed
			end
			
			def remove(track)
				unless track.is_a?(Track)
					raise ArgumentError, "track variable must be a Track instance. #{track.class} given."
				end
				
				puts "stack tracks: #{@tracks.count}" # @TODO remove
				
				puts "stack track to remove: #{track.short_id} #{track.object_id}"
				@tracks.each do |track|
					puts "stack track: #{track.short_id} #{track.object_id}"
				end
				
				r = @tracks.delete(track)
				
				puts "stack tracks delete: #{r}" # @TODO remove
				puts "stack left tracks: #{@tracks.count}" # @TODO remove
				
				# Mark Stack as changed.
				changed
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
				
				@tracks = @data.map{ |ids|
					task_id, track_id = ids
					
					begin
						task = @timr.get_task_by_id(task_id)
						if task
							track = task.find_track_by_id(track_id)
						end
					rescue Exception => e
						# Mark Stack as changed.
						changed
						
						nil
					end
				}.select{ |track|
					!track.nil?
				}
			end
			
			def to_s
				"Stack"
			end
			
			def inspect
				"#<Stack tracks=#{@tracks.count} current=#{@current_track.short_id}>"
			end
			
		end # class Task
		
	end # module Timr
end #module TheFox
