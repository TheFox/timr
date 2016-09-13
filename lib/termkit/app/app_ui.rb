
module TheFox
	module TermKit
		
		class UIApp < App
			
			attr_accessor :app_controller
			attr_accessor :active_controller
			
			def initialize
				super()
				
				#puts 'UIApp initialize'
				
				@render_count = 0
				@app_controller = nil
				@active_controller = nil
				
				ui_init
			end
			
			def run_cycle
				super()
				
				#puts 'UIApp->run_cycle'
				
				render
			end
			
			def set_app_controller(app_controller)
				if !app_controller.is_a?(AppController)
					raise ArgumentError, "Argument is not a AppController -- #{app_controller.class} given"
				end
				
				@app_controller = app_controller
			end
			
			def set_active_controller(active_controller)
				if !active_controller.is_a?(ViewController)
					raise ArgumentError, "Argument is not a ViewController -- #{active_controller.class} given"
				end
				
				if !@active_controller.nil?
					@active_controller.inactive
				end
				
				@active_controller = active_controller
				@active_controller.active
			end
			
			def render
				logger.debug('--- RENDER ---')
				
				sleep 1 # @TODO: remove this line
				
				@render_count += 1
				draw_line(Point.new(0, 0), "RENDER: #{@render_count}")
				if !@active_controller.nil?
					logger.debug('RENDER active_controller OK')
					
					@active_controller.render.each do |y_pos, row|
						row.each do |x_pos, view_content|
							sleep 0.1 # @TODO: remove this line
							
							logger.debug("RENDER #{x_pos}:#{y_pos}: '#{view_content}'")
							
							if view_content.needs_rendering
								draw_point(Point.new(x_pos, y_pos), content.render)
							end
							
							ui_refresh
						end
					end
				end
				ui_refresh
			end
			
			def draw_line(point, content)
				raise NotImplementedError
			end
			
			def draw_point(point, content)
				raise NotImplementedError
			end
			
			def ui_refresh
				raise NotImplementedError
			end
			
			def ui_max_x
				-1
			end
			
			def ui_max_y
				-1
			end
			
			protected
			
			def app_will_terminate
				#puts 'UIApp app_will_terminate'
				
				ui_close
			end
			
			def ui_init
				# raise NotImplementedError
			end
			
			def ui_close
				# raise NotImplementedError
			end
			
			def key_down(key)
				if !key.nil? && !@active_controller.nil?
					event = KeyEvent.new
					event.key = key
					
					begin
						@active_controller.handle_event(event)
					rescue Exception::UnhandledKeyEventException => e
						if @app_controller.nil?
							raise e
						end
						
						@app_controller.handle_event(e.event)
					rescue Exception::UnhandledEventException => e
						draw_line(Point.new(0, 0), 'UnhandledEventException')
					end
				end
			end
			
		end
		
	end
end
