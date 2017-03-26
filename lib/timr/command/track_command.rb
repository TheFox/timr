
module TheFox
	module Timr
		module Command
			
			# - Print Track informations.
			# - Add/remove a Track.
			class TrackCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Error
				
				def initialize(argv = [])
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					@show_opt = false
					@add_opt = false
					
					@tracks_opt = Set.new
					@task_opt = false
					@message_opt = nil
					@start_date_opt = nil
					@start_time_opt = nil
					@end_date_opt = nil
					@end_time_opt = nil
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						when '-t', '--task'
							@task_opt = true
						
						when '-m', '--message'
							@message_opt = argv.shift
						when '--sd', '--start-date'
							@start_date_opt = argv.shift
						when '--st', '--start-time'
							@start_time_opt = argv.shift
						when '--ed', '--end-date'
							@end_date_opt = argv.shift
						when '--et', '--end-time'
							@end_time_opt = argv.shift
						
						when 'show'
							@show_opt = true
						when 'add'
							@add_opt = true
						
						else
							if /[a-f0-9]+/i.match(arg)
								@tracks_opt << arg
							else
								raise TrackCommandError, "Unknown argument '#{arg}'. See 'timr track --help'."
							end
						end
					end
				end
				
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					@timr.load_all_tracks
					
					if @task_opt
						run_task_command
					elsif @add_opt
						run_add
					else
						run_show
					end
				end
				
				private
				
				def run_task_command
					tasks = Hash.new # Set.new
					
					@tracks_opt.each do |track_id|
						track = @timr.get_track_by_id(track_id)
						task = track.task
						
						unless tasks.has_key?(task.id)
							tasks[task.id] = task
						end
					end
					
					task_command = TaskCommand.new(tasks.values)
					task_command.run
				end
				
				def run_show
					tracks = Array.new
					@tracks_opt.each do |track_id|
						track = @timr.get_track_by_id(track_id)
						unless track
							raise TrackCommandError, "Track for ID '#{track_id}' not found."
						end
						
						tracks << track_to_array(track)
					end
					
					if tracks.count > 0
						puts tracks.map{ |track_s| track_s.join("\n") }.join("\n\n")
					end
				end
				
				def run_add
					if @tracks_opt.count == 0
						raise TrackCommandError, 'No Task ID given.'
					end
					task_id = @tracks_opt.first
					
					if @start_date_opt.nil? && @start_time_opt.nil? &&
						@end_date_opt.nil? && @end_time_opt.nil? &&
						@message_opt.nil?
						
						raise TaskCommandError, "No option given. See 'timr track --help'."
					end
					if @start_date_opt || @start_time_opt ||
						@end_date_opt || @end_time_opt
						
						if @start_date_opt.nil?
							raise TaskCommandError, 'Start Date must be given.'
						end
						if @start_time_opt.nil?
							raise TaskCommandError, 'Start Time must be given.'
						end
						
						if @end_date_opt.nil?
							raise TaskCommandError, 'End Date must be given.'
						end
						if @end_time_opt.nil?
							raise TaskCommandError, 'End Time must be given.'
						end
					end
					
					task = @timr.get_task_by_id(task_id)
					
					track = Track.new
					if @start_date_opt && @start_time_opt
						track.begin_datetime = Time.parse("#{@start_date_opt} #{@start_time_opt}")
					end
					if @end_date_opt && @end_time_opt
						track.end_datetime = Time.parse("#{@end_date_opt} #{@end_time_opt}")
					end
					if @message_opt
						track.message = @message_opt
					end
					
					task.add_track(track)
					task.save_to_file
					
					puts track_to_array(track).join("\n")
				end
				
				# Is used to print the Task to STDOUT.
				def track_to_array(track)
					task = track.task
					
					track_s = Array.new
					track_s << ' Task: %s %s' % [task.short_id, task.name_s]
					track_s << 'Track: %s %s' % [track.short_id, track.name]
					
					duration_human = track.duration.to_human
					track_s << '  Duration: %s' % [duration_human]
					
					duration_man_days = track.duration.to_man_days
					if duration_human != duration_man_days
						track_s << '  Man Unit: %s' % [duration_man_days]
					end
					
					if track.begin_datetime
						track_s << '  Begin: %s' % [track.begin_datetime_s]
					end
					
					if track.end_datetime
						track_s << '  End:   %s' % [track.end_datetime_s]
					end
					
					status = track.status.colorized
					track_s << '  Status: %s' % [status]
					if track.message
						track_s << '  Message: %s' % [track.message]
					end
					
					track_s << '  File path: %s' % [task.file_path]
					
					track_s
				end
				
				def help
					puts 'usage: timr track [show] [-t|--task] <track_ids...>'
					puts '   or: timr track add [-m|--message <message>]'
					puts '                      [--start-date <YYYY-MM-DD> --start-time <HH:MM[:SS]>'
					puts '                        [--end-date <YYYY-MM-DD> --end-time <HH:MM[:SS]>]]'
					puts '                      <task_id>'
					puts '   or: timr track [-h|--help]'
					puts
					puts 'Show Options'
					puts "    -t, --task       Show Task of Track. Same as 'timr task <task_id>'."
					puts
					puts 'Add Options'
					puts '    -m, --message                          Track Message. What have you done?'
					puts '    --sd, --start-date <YYYY-MM-DD>        Start Date'
					puts '    --st, --start-time <HH:MM[:SS]>        Start Time'
					puts '    --ed, --end-date <YYYY-MM-DD>          End Date'
					puts '    --et, --end-time <HH:MM[:SS]>          End Time'
					puts
					puts 'Start DateTime must be given when End DateTime is given. A Track cannot have a'
					puts 'End DateTime without a Start DateTime.'
					puts
					puts 'Man Unit: 8 hours are 1 man-day.'
					puts '          5 man-days are 1 man-week, and so on.'
					puts
				end
				
			end # class TrackCommand
			
		end # module Command
	end # module Timr
end # module TheFox
