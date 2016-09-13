
module TheFox
	module TermKit
		module Test
			
			class App < TheFox::TermKit::App
				
				protected
				
				def app_will_terminate
					# puts 'Test::App->app_will_terminate'
					42
				end
				
			end
		
		end
	end
end
