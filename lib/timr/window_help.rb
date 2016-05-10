
module TheFox
	module Timr
		
		class HelpWindow < Window
			
			def content
				[
					'#### Help ####',
					'',
					'           n .. Create a New Task',
					'           c .. Current Task: Start/Continue',
					'           x .. Current Task: Stop',
					'           v .. Current Task: Stop and Pop from Stack',
					'        p, b .. Push and start selected Task.',
					'           r .. Refresh Window',
					'           w .. Write all changes.',
					'           q .. Exit',
					'           h .. Help',
					'           1 .. Timeline Window',
					'           2 .. Tasks Window',
					'      RETURN .. Start selected task.',
					'      KEY UP .. Move Cursor up.',
					'    KEY DOWN .. Move Cursor down.',
					'',
					'Current Task Status',
					'',
					"    #{TASK_NO_TASK_LOADED_C} .. No task loaded.",
					'    | .. Task stopped.',
					'    > .. Task is running.',
					#'',
				]
			end
			
		end
		
	end
end
