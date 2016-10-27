
require 'termkit'

module TheFox
	module Timr
		
		class AppController < TheFox::TermKit::AppController
			
			include TheFox::TermKit
			
			def handle_event(event)
				#Curses.setpos(3, 0)
				#Curses.addstr("APP  CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(KeyEvent)
					#Curses.setpos(1, 0)
					#Curses.addstr("APP  HANDLED: #{event.key}   ")
					
					case event.key
					when ?w, 3, 4
						#puts "#{self.class} #{event.key}"
						
					when ?q
						#puts "#{self.class} #{event.key}"
						
						@app.terminate
					else
						#raise Exception::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
						
						if !@app.nil? && !@app.logger.nil?
							@app.logger.warn("Timr AppController, Unhandled Key Event: #{event}")
						end
					end
				else
					#raise Exception::UnhandledEventException.new(event), "Unhandled event: #{event}"
					
					if !@app.nil? && !@app.logger.nil?
						@app.logger.warn("Timr AppController, Unhandled Event: #{event}")
					end
				end
			end
			
		end
		
	end
end
