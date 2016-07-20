
module TheFox
	module Timr
		
		class ContainerController < TheFox::TermKit::Controller
			
			def initialize(app)
				super()
				
				puts "ContainerController initialize: #{app}"
				
				@app = app
				@active_controller = nil
				@timelineController = TheFox::Timr::TimelineController.new
				@tasksController = TheFox::Timr::TasksController.new
				@helpController = TheFox::Timr::HelpController.new
				
				add_child_controller(@timelineController)
				add_child_controller(@tasksController)
				add_child_controller(@helpController)
			end
			
			def key_down(key)
				puts "ContainerController key_down #{key}"
			end
			
		end
		
	end
end
