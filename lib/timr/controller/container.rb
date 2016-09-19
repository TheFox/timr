
require 'termkit'

module TheFox
	module Timr
		
		class ContainerController < TheFox::TermKit::Controller
			
			include TheFox::TermKit
			
			def initialize(app)
				super()
				
				puts "ContainerController initialize: #{app}"
				
				@app = app
				@active_controller = nil
				@timelineController = TimelineController.new
				@tasksController = TasksController.new
				@helpController = HelpController.new
				
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
