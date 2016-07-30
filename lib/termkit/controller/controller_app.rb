
module TheFox
	module TermKit
		
		class AppController < Controller
			
			def initialize(app)
				if !app.is_a?(App)
					raise ArgumentError, "Argument is not a App -- #{app.class} given"
				end
				
				super()
				
				@app = app
				
				#puts 'AppController->initialize'
			end
			
		end
		
	end
end
