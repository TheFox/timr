
module TheFox
	module Timr
		module Command
			
			# Push a new [Track](rdoc-ref:TheFox::Timr::Model::Track) to the [Stack](rdoc-ref:TheFox::Timr::Model::Stack).
			# 
			# Man page: [timr-push(1)](../../../../man/timr-push.1.html)
			class PushCommand < BasicCommand
				
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/timr-push.1'
				
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
								raise PushCommandError, "Unknown argument '#{arg}'. See 'timr push --help'."
							else
								if @id_opts.length < 2
									@id_opts << arg
								else
									raise PushCommandError, "Unknown argument '#{arg}'. See 'timr push --help'."
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
					
					# See BasicCommand class.
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
					
					track = @timr.push(options)
					unless track
						raise TrackError, 'Could not start a new Track.'
					end
					
					puts '--- PUSHED ---'
					puts track.to_compact_str
					puts @timr.stack
				end
				
				private
				
				def help
					start_command = StartCommand.new(['--help'])
					start_command.run
					start_command.shutdown
				end
				
			end # class PushCommand
			
		end # module Command
	end # module Timr
end # module TheFox
