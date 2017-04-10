
module TheFox
	module Timr
		module Model
			
			class ForeignIdDb < BasicModel
				
				include TheFox::Timr::Error
				
				attr_reader :foreign_ids
				
				def initialize
					super()
					
					@foreign_ids = Hash.new
				end
				
				def add_task(task, foreign_id)
					task_id = task.id
					foreign_id = foreign_id.strip # needs clone
					
					if @foreign_ids[foreign_id]
						if @foreign_ids[foreign_id] == task_id
							# Foreign ID has already a match.
							false
						else
							raise ForeignIdError, "Want to add Foreign ID '#{foreign_id}' for Task '#{task.short_id}', but Foreign ID '#{foreign_id}' is already used by Task '#{@foreign_ids[foreign_id]}'."
						end
					else
						@foreign_ids[foreign_id] = task_id
						
						task.foreign_id = foreign_id
						
						# Mark ForeignIdDb as changed.
						changed
						
						true
					end
				end
				
				def get_task_id(foreign_id)
					foreign_id = foreign_id.strip # needs clone
					
					@foreign_ids[foreign_id]
				end
				
				def remove_task(task)
					@foreign_ids.delete(task.foreign_id)
					
					task.foreign_id = nil
					
					# Mark ForeignIdDb as changed.
					changed
				end
				
				private
				
				# BasicModel Hook
				def pre_save_to_file
					@data = @foreign_ids
				end
				
				# BasicModel Hook
				def post_load_from_file
					@foreign_ids = @data
				end
				
			end # class ForeignIdDb
			
		end # module Model
	end # module Timr
end #module TheFox
