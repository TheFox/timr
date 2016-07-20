
module TheFox
	module TermKit
		
		class AppController < Controller
			
			def initialize(app)
				if !app.is_a?(App)
					raise "app is wrong class: #{app.class}"
				end
				
				super()
				
				@app = app
				
				#puts 'AppController initialize'
			end
			
		end
		
	end
end
