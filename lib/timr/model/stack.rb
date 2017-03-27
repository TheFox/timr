
module TheFox
	module Timr
		module Model
			
			# The Stack holds one or more Tracks.
			# Only one Track can run at a time.
			# If you push a new Track on the Stack the underlying running
			# will be paused.
			class Stack < BasicModel
				
				include TheFox::Timr::Helper
				
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
						raise StackError, "track variable must be a Track instance. #{track.class} given."
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
						raise StackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					@tracks << track
					
					# Mark Stack as changed.
					changed
				end
				
				def remove(track)
					unless track.is_a?(Track)
						raise StackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					# puts "stack tracks: #{@tracks.count}" # @TODO remove
					
					# puts "stack track to remove: #{track.short_id} #{track.object_id}" # @TODO remove
					# @tracks.each do |track|
					# 	puts "stack track: #{track.short_id} #{track.object_id}" # @TODO remove
					# end
					
					r = @tracks.delete(track)
					
					# puts "stack tracks delete: #{r.class}" # @TODO remove
					# puts "stack left tracks: #{@tracks.count}" # @TODO remove
					
					# Mark Stack as changed.
					changed
				end
				
				# BasicModel Hook
				def pre_save_to_file
					# Tracks
					@data = @tracks.map{ |track| [track.task.id, track.id] }
					
					super()
				end
				
				# BasicModel Hook
				def post_load_from_file
					#puts "Stack post_load_from_file" # @TODO remove
					
					unless @timr
						raise StackError, 'Stack: @timr variable is not set.'
					end
					
					@tracks = @data.map{ |ids|
						task_id, track_id = ids
						
						begin
							task = @timr.get_task_by_id(task_id)
							if task
								track = task.find_track_by_id(track_id)
								
								if track.nil?
									# Task file was found but no Track with ID from Stack.
									
									# Mark Stack as changed.
									changed
									
									nil
								else
									track
								end
							end
						rescue Exception => e
							# Task file for ID from Stack was not found.
							
							# Mark Stack as changed.
							changed
							
							nil
						end
					}.select{ |track|
						# puts "track found B: #{track.class}" # @TODO remove
						!track.nil?
					}
				end
				
				def to_s
					# "Stack"
					
					tracks_s = TranslationHelper.pluralize(@tracks.count, 'track', 'tracks')
					'Stack: %s' % [tracks_s]
				end
				
				def inspect
					"#<Stack tracks=#{@tracks.count} current=#{@current_track.short_id}>"
				end
				
			end # class Task
		
		end # module Model
	end # module Timr
end #module TheFox
