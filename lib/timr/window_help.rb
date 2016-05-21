
module TheFox
	module Timr
		
		class HelpWindow < Window
			
			def content
				[
					'#### Help ####',
					'',
					'         n .. Create a new Task and start',
					'         t .. Create a new Task',
					'         c .. Current Task: Start/Continue',
					'         x .. Current Task: Stop',
					'         v .. Current Task: Stop and Pop from Stack',
					'         f .. Stop and deselect all Tasks on the Stack',
					'      p, b .. Push and start selected Task.',
					'         r .. Refresh Window',
					'         w .. Write all changes.',
					'         q .. Exit',
					'         h .. Help',
					'         1 .. Timeline Window',
					'         2 .. Tasks Window',
					'    RETURN .. Start selected Task.',
					'         # .. Start selected Task, edit Track Description.',
					'    KEY UP .. Move Cursor up.',
					'  KEY DOWN .. Move Cursor down.',
					'',
					'Current Task Status',
					'',
					"         #{TASK_NO_TASK_LOADED_CHAR} .. No Task loaded.",
					'         | .. Task stopped.',
					'         > .. Task is running.',
				]
			end
			
		end
		
	end
end
