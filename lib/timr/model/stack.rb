
module TheFox
	module Timr
		module Model
			
			# The Stack holds one or more [Tracks](rdoc-ref:TheFox::Timr::Model::Track). Only one Track can run at a time.
			# 
			# When you push a new Track on the Stack the underlying running will be paused.
			# 
			# Do not call Stack methods from extern. Only the Timr class is responsible to call Stack methods.
			class Stack < BasicModel
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Timr instance.
				attr_accessor :timr
				
				# Holds all Tracks.
				attr_reader :tracks
				
				def initialize
					super()
					
					@timr = nil
					
					# Data
					@tracks = Array.new
				end
				
				# Get the current Track (Top Track).
				def current_track
					@tracks.last
				end
				
				# Start a Track.
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
				
				# Stop current running Track.
				def stop
					if @tracks.count > 0
						@tracks.pop
						
						# Mark Stack as changed.
						changed
					end
				end
				
				# Push a Track.
				def push(track)
					unless track.is_a?(Track)
						raise StackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					@tracks << track
					
					# Mark Stack as changed.
					changed
				end
				
				# Remove a Track.
				def remove(track)
					unless track.is_a?(Track)
						raise StackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					@tracks.delete(track)
					
					# Mark Stack as changed.
					changed
				end
				
				# Check Track on Stack.
				def on_stack?(track)
					unless track.is_a?(Track)
						raise StackError, "track variable must be a Track instance. #{track.class} given."
					end
					
					@tracks.include?(track)
				end
				
				# Append a Track.
				def <<(track)
					@tracks << track
				end
				
				# To String
				def to_s
					tracks_s = TranslationHelper.pluralize(@tracks.count, 'track', 'tracks')
					'Stack: %s' % [tracks_s]
				end
				
				def inspect
					"#<Stack tracks=#{@tracks.count} current=#{@current_track.short_id}>"
				end
				
				private
				
				# BasicModel Hook
				def pre_save_to_file
					# Tracks
					@data = @tracks.map{ |track| [track.task.id, track.id] }
					
					super()
				end
				
				# BasicModel Hook
				def post_load_from_file
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
						rescue TimrError
							# Task file for ID from Stack was not found.
							
							# Mark Stack as changed.
							changed
							
							nil
						end
					}.select{ |track|
						!track.nil?
					}
				end
				
			end # class Task
		
		end # module Model
	end # module Timr
end #module TheFox
