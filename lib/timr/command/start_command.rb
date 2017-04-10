
require 'tempfile'

module TheFox
	module Timr
		module Command
			
			# Start a new [Track](rdoc-ref:TheFox::Timr::Model::Track).
			class StartCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/start.1'
				
				def initialize(argv = Array.new)
					super()
					
					@help_opt = false
					
					@foreign_id_opt = nil
					@name_opt = nil
					@description_opt = nil
					@estimation_opt = nil
					
					@hourly_rate_opt = nil
					@has_flat_rate_opt = nil
					
					@date_opt = nil
					@time_opt = nil
					@message_opt = nil
					@edit_opt = false
					
					@task_id_opt = nil
					@track_id_opt = nil
					@id_opts = Array.new
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						
						when '--id'
							@foreign_id_opt = argv.shift.strip
						when '-n', '--name'
							@name_opt = argv.shift
						when '--desc', '--description'
							@description_opt = argv.shift
						when '-e', '--est', '--estimation'
							@estimation_opt = argv.shift
						
						when '-r', '--hourly-rate'
							@hourly_rate_opt = argv.shift
						when '--fr', '--flat', '--flat-rate'
							@has_flat_rate_opt = true
						
						when '-d', '--date'
							@date_opt = argv.shift
						when '-t', '--time'
							@time_opt = argv.shift
						when '-m', '--message'
							@message_opt = argv.shift
						when '--edit'
							@edit_opt = true
						else
							if arg[0] == '-'
								raise StartCommandError, "Unknown argument '#{arg}'. See 'timr start --help'."
							else
								if @id_opts.length < 2
									@id_opts << arg
								else
									raise StartCommandError, "Unknown argument '#{arg}'. See 'timr start --help'."
								end
							end
						end
					end
					
					check_foreign_id(@foreign_id_opt)
					
					if @id_opts.length
						@task_id_opt, @track_id_opt = @id_opts
					end
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					run_edit
					
					options = {
						:foreign_id => @foreign_id_opt,
						:name => @name_opt,
						:description => @description_opt,
						:estimation => @estimation_opt,
						
						:hourly_rate => @hourly_rate_opt,
						:has_flat_rate => @has_flat_rate_opt,
						
						:date => @date_opt,
						:time => @time_opt,
						:message => @message_opt,
						
						:task_id => @task_id_opt,
						:track_id => @track_id_opt,
					}
					
					track = @timr.start(options)
					unless track
						raise TrackError, 'Could not start a new Track.'
					end
					
					puts track.to_detailed_str
					puts @timr.stack
				end
				
				private
				
				def help
					puts 'usage: timr start [--id <str>]'
					puts '                  [-n|--name <name>] [--desc|--description <description>]'
					puts '                  [[-d|--date <date>] -t|--time <time>]'
					puts '                  [-m|--message <message>] [--edit] [--estimation <time>]'
					puts '                  [--hourly-rate <value>] [--flat-rate]'
					puts '                  [<task_id> [<track_id>]]'
					puts '   or: timr start [-h|--help]'
					puts
					puts "Note: 'timr push' uses the same options."
					puts
					puts 'Task Options'
					puts '    --id <str>                        Your ID to identify the Task.'
					puts '    -n, --name <name>                 The name of the new Task.'
					puts '    --desc, --description <str>       Longer description of the new Task.'
					puts '    -e, --est, --estimation <time>    Task Estimation. See details below.'
					puts '    -r, --hourly-rate <value>         Set the Hourly Rate.'
					puts '    --fr, --flat-rate, --flat         Has Task a Flat Rate?'
					puts
					puts 'Track Options'
					puts '    -m, --message <message>    Track Message. What have you done?'
					puts '                               You can overwrite this on stop command.'
					puts '    --edit                     Edit Track Message when providing <track_id>.'
					puts '                               EDITOR environment variable must be set.'
					puts '    -d, --date <date>          Track Start Date. Default: today'
					puts '    -t, --time <time>          Track Start Time. Default: now'
					puts
					puts 'Arguments'
					HelpCommand.print_id_help
					puts
					HelpCommand.print_datetime_help
					puts
					HelpCommand.print_estimation_help
					puts
				end
				
			end # class StartCommand
			
		end # module Command
	end # module Timr
end # module TheFox
