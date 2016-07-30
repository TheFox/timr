
module TheFox
	module Timr
		
		class AppController < TheFox::TermKit::AppController
			
			def handle_event(event)
				#Curses.setpos(3, 0)
				#Curses.addstr("APP  CONTROLLER: #{event.key}    #{event.class}")
				
				if event.is_a?(TheFox::TermKit::KeyEvent)
					Curses.setpos(1, 0)
					Curses.addstr("APP  HANDLED: #{event.key}   ")
					
					case event.key
					when ?w, 3, 4
						#puts "#{self.class} #{event.key}"
						
					when ?q
						#puts "#{self.class} #{event.key}"
						
						@app.terminate
					else
						raise TheFox::TermKit::Exception::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
					end
				else
					raise TheFox::TermKit::Exception::UnhandledEventException.new(event), "Unhandled event: #{event}"
				end
			end
			
		end
		
	end
end
