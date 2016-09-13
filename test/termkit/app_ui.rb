
module TheFox
	module TermKit
		module Test
			
			class UIApp < TheFox::TermKit::UIApp
				
				def test_ui_init
					ui_init
				end
				
				def test_key_down(key)
					key_down(key)
				end
				
				protected
				
				def ui_close
					# puts 'Test::App->app_will_terminate'
					42
				end
				
			end
		
		end
	end
end
