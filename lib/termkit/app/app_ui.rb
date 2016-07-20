
module TheFox
	module TermKit
		
		class UIApp < App
			
			def initialize
				super()
				
				#puts 'UIApp initialize'
				
				@app_controller = nil
				@active_controller = nil
				
				ui_init
			end
			
			def run_cycle
				super()
				
				#puts 'UIApp run_cycle'
				
				render
			end
			
			# def terminate
			# 	puts 'UIApp terminate'
				
			# 	ui_close
				
			# 	super()
			# end
			
			def set_app_controller(app_controller)
				if !app_controller.is_a?(AppController)
					raise "app_controller is wrong class: #{app_controller.class}"
				end
				
				@app_controller = app_controller
			end
			
			def set_active_controller(active_controller)
				if !active_controller.is_a?(ViewController)
					raise "active_controller is wrong class: #{active_controller.class}"
				end
				
				if !@active_controller.nil?
					@active_controller.inactive
				end
				
				@active_controller = active_controller
				@active_controller.active
			end
			
			def render
				@active_controller.render_view
				
			end
			
			def print_line(point, content)
				
			end
			
			protected
			
			def app_will_terminate
				#puts 'UIApp app_will_terminate'
				
				ui_close
			end
			
			def ui_init
				#puts 'UIApp ui_init'
			end
			
			def ui_close
				#puts 'UIApp ui_close'
			end
			
			def key_down(key)
				if !key.nil? && !@active_controller.nil?
					event = KeyEvent.new
					event.key = key
					
					begin
						@active_controller.handle_event(event)
					rescue UnhandledKeyEventException => e
						if @app_controller.nil?
							raise e
						end
						
						@app_controller.handle_event(e.event)
					end
					
				end
			end
			
		end
		
	end
end
