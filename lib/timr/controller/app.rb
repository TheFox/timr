
module TheFox
	module Timr
		
		class AppController < TheFox::TermKit::AppController
			
			def handle_event(event)
				#Curses.setpos(3, 0)
				#Curses.addstr("APP  CONTROLLER: #{event.key}    #{event.class}")
				
				case event.key
				when ?w, 3, 4
					#puts "#{self.class} #{event.key}"
					Curses.setpos(2, 0)
					Curses.addstr("HANDLED: #{event.key}   ")
				when ?q
					#puts "#{self.class} #{event.key}"
					
					@app.terminate
				else
					case event.key.ord
					when 3, 4
						#puts "#{self.class} #{event.key}"
						
						@app.terminate
					else
						raise TheFox::TermKit::UnhandledKeyEventException.new(event), "Unhandled event: #{event}"
					end
				end
			end
			
		end
		
	end
end
