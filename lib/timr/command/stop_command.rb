
module TheFox
	module Timr
		module Command
			
			# Stop the current running [Track](rdoc-ref:TheFox::Timr::Model::Track).
			class StopCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/stop.1'
				
				def initialize(argv = Array.new)
					super()
					
					@help_opt = false
					
					@start_date_opt = nil
					@start_time_opt = nil
					@end_date_opt = nil
					@end_time_opt = nil
					
					@message_opt = nil
					@edit_opt = false
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						
						when '--sd', '--start-date'
							@start_date_opt = argv.shift
						when '--st', '--start-time'
							@start_time_opt = argv.shift
						
						when '--ed', '--end-date', '-d', '--date'
							@end_date_opt = argv.shift
						when '--et', '--end-time', '-t', '--time'
							@end_time_opt = argv.shift
						
						when '-m', '--message'
							@message_opt = argv.shift
						when '--edit'
							@edit_opt = true
						else
							raise StopCommandError, "Unknown argument '#{arg}'. See 'timr stop --help'."
						end
					end
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					track = @timr.stack.current_track
					if track
						task = track.task
						if task
							run_edit(task.id, track.id)
						end
					end
					
					options = {
						:start_date => @start_date_opt,
						:start_time => @start_time_opt,
						
						:end_date => @end_date_opt,
						:end_time => @end_time_opt,
						
						:message => @message_opt,
					}
					
					track = @timr.stop(options)
					unless track
						puts 'No running Track to stop.'
						return
					end
					
					puts track.to_compact_str
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr stop [-m|--message <message>] [--edit]'
					puts '                 [[--start-date <date>] --start-time <time>]'
					puts '                 [-d|--date <date>] [-t|--time <time>]'
					puts '   or: timr stop [-h|--help]'
					puts
					puts 'Track Options'
					puts '    -m, --message <message>    Track Message. What have you done? This will'
					puts '                               overwrite the start message. See --edit option.'
					puts '    --edit                     Edit Track Message.'
					puts '                               EDITOR environment variable must be set.'
					puts
					puts '    --sd, --start-date <date>    Overwrite the Start date.'
					puts '    --st, --start-time <time>    Overwrite the Start time.'
					puts
					puts '    --ed, --end-date <date>      Track End Date. Default: today'
					puts '    --et, --end-time <time>      Track End Time. Default: now'
					puts
					puts '    -d, --date <date>            --end-date alias.'
					puts '    -t, --time <time>            --end-time alias.'
					puts
					HelpCommand.print_datetime_help
					puts
				end
				
			end # class StopCommand
			
		end # module Command
	end # module Timr
end # module TheFox
