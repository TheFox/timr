
module TheFox
	module Timr
		
		class Config < Model
			
			attr_accessor :inital_version
			attr_accessor :last_used_version
			
			def initialize
				super()
				
				@inital_version = nil
				@last_used_version = nil
			end
			
			def pre_save_to_file
				@data = {
					'inital_version' => @inital_version || VERSION,
					'last_used_version' => VERSION,
				}
			end
			
			def post_load_from_file
				puts "Config post_load_from_file"
				
				@inital_version = @data['inital_version'] || VERSION
				@last_used_version = @data['last_used_version']
				
				puts "Config inital_version: '#{@inital_version}'"
				puts "Config last_used_version: '#{@last_used_version}'"
				
				if @last_used_version != VERSION
					@last_used_version = VERSION
					
					# Mark Config as changed.
					changed
				end
			end
			
		end # class Config
		
	end # module Timr
end #module TheFox
