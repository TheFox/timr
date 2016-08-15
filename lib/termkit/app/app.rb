
require 'logger'

module TheFox
	module TermKit
		
		class App
			
			def initialize
				@exit = false
				
				@logger = Logger.new('termkit_app.log')
				@logger.level = Logger::DEBUG
			end
			
			def logger=(logger)
				@logger = logger
			end
			
			def logger
				@logger
			end
			
			def run
				#puts 'App run'
				
				loop_cycle = 0
				while !@exit
					loop_cycle += 1
					
					run_cycle
					#sleep @run_cycle_sleep
				end
			end
			
			def run_cycle
				#puts 'App run_cycle'
			end
			
			def terminate
				if !@exit
					#puts 'App->terminate'
					
					@exit = true
					
					app_will_terminate
				end
			end
			
			protected
			
			def app_will_terminate
				#puts 'App->app_will_terminate'
			end
			
		end
		
	end
end
