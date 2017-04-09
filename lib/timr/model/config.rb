
module TheFox
	module Timr
		module Model
			
			class Config < BasicModel
				
				# The version String which the file was created with.
				attr_accessor :inital_version
				
				# The version of the previous Timr run.
				attr_accessor :last_used_version
				
				def initialize
					super()
					
					@inital_version = nil
					@last_used_version = nil
				end
				
				private
				
				# BasicModel Hook
				def pre_save_to_file
					@data = {
						'inital_version' => @inital_version || VERSION,
						'last_used_version' => VERSION,
					}
				end
				
				# BasicModel Hook
				def post_load_from_file
					@inital_version = @data.fetch('inital_version', VERSION)
					@last_used_version = @data.fetch('last_used_version', VERSION)
					
					if @last_used_version != VERSION
						@last_used_version = VERSION
						
						# Mark Config as changed.
						changed
					end
				end
				
			end # class Config
			
		end # module Model
	end # module Timr
end #module TheFox
