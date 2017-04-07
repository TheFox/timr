
module TheFox
	module Timr
		module Command
			
			# - Print informations about a specific [Track](rdoc-ref:TheFox::Timr::Model::Track).
			# - Add/remove a Track.
			# - Edit (set) a Track.
			class TrackCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/track.1'
				
				def initialize(argv = Array.new)
					super()
					# puts "argv '#{argv}'"
					
					@help_opt = false
					@show_opt = false
					@add_opt = false
					@remove_opt = false
					@set_opt = false
					
					@tracks_opt = Set.new
					@task_opt = false
					@task_id_opt = nil
					@message_opt = nil
					@start_date_opt = nil
					@start_time_opt = nil
					@end_date_opt = nil
					@end_time_opt = nil
					@billed_opt = nil
					@unbilled_opt = nil
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						when '-t', '--task'
							if @set_opt
								@task_id_opt = argv.shift
							else
								@task_opt = true
							end
						
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
						when '-b', '--billed'
							@billed_opt = true
						when '--unbilled'
							@unbilled_opt = true
						
						when 'show'
							@show_opt = true
						when 'add'
							@add_opt = true
						when 'remove'
							@remove_opt = true
						when 'set'
							@set_opt = true
						
						else
							if /^[a-f0-9]{4,40}$/i.match(arg)
								@tracks_opt << arg
							else
								raise TrackCommandError, "Unknown argument '#{arg}'. See 'timr track --help'."
							end
						end
					end
					
					if @billed_opt && @unbilled_opt
						raise TrackCommandError, 'Cannot use --billed and --unbilled.'
					end
				end
				
				# See BasicCommand#run.
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
					elsif @remove_opt
						run_remove
					elsif @set_opt
						run_set
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
					task_id = check_task_id
					
					check_opts_add
					
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
					if @billed_opt || @unbilled_opt
						if @billed_opt
							track.is_billed = true
						else
							track.is_billed = false
						end
					end
					
					task.add_track(track)
					task.save_to_file
					
					puts track_to_array(track).join("\n")
				end
				
				def run_remove
					@tracks_opt.each do |track_id|
						task_track_h = @timr.remove_track({:track_id => track_id})
						
						task = task_track_h[:task]
						track = task_track_h[:track]
						
						puts 'Deleted Track %s from Task %s.' % [track.short_id, task.short_id]
					end
				end
				
				def run_set
					track_id = check_track_id
					
					check_opts_set
					
					track = @timr.get_track_by_id(track_id)
					unless track
						raise TrackError, "Track for ID '#{track_id}' not found."
					end
					
					puts '--- OLD ---'
					puts track_to_array(track).join("\n")
					puts
					
					bdt = track.begin_datetime
					edt = track.end_datetime
					
					# Start DateTime
					if @start_date_opt && @start_time_opt
						track.begin_datetime = "#{@start_date_opt}T#{@start_time_opt}"
					elsif @start_date_opt.nil? && @start_time_opt
						if bdt
							track.begin_datetime = "#{bdt.strftime('%F')}T#{@start_time_opt}"
						else
							raise TrackCommandError, 'Start Date must be given. Track has no Start DateTime.'
						end
					elsif @start_date_opt && @start_time_opt.nil?
						if bdt
							track.begin_datetime = "#{@start_date_opt}T#{bdt.strftime('%T%z')}"
						else
							raise TrackCommandError, 'Start Time must be given. Track has no Start DateTime.'
						end
					# elsif @start_date_opt.nil? && @start_time_opt.nil?
					# 	raise TrackCommandError, 'Start Date or Start Time must be given.'
					end
					
					# End DateTime
					if @end_date_opt && @end_time_opt
						track.end_datetime = "#{@end_date_opt}T#{@end_time_opt}"
					elsif @end_date_opt.nil? && @end_time_opt
						if edt
							track.end_datetime = "#{edt.strftime('%F')}T#{@end_time_opt}"
						else
							raise TrackCommandError, 'End Date must be given. Track has no End DateTime.'
						end
					elsif @end_date_opt && @end_time_opt.nil?
						if edt
							track.end_datetime = "#{@end_date_opt}T#{edt.strftime('%T%z')}"
						else
							raise TrackCommandError, 'End Time must be given. Track has no End DateTime.'
						end
					# elsif @end_date_opt.nil? && @end_time_opt.nil?
					# 	raise TrackCommandError, 'End Date or End Time must be given.'
					end
					
					# Message
					if @message_opt
						track.message = @message_opt
					end
					
					# Billed / Unbilled
					if @billed_opt || @unbilled_opt
						if @billed_opt
							track.is_billed = true
						else
							track.is_billed = false
						end
					end
					
					task = track.task
					
					if @task_id_opt
						target_task = @timr.get_task_by_id(@task_id_opt)
						
						task.move_track(track, target_task)
						
						target_task.save_to_file
					end
					
					task.save_to_file
					
					puts '--- NEW ---'
					puts track_to_array(track).join("\n")
				end
				
				# Is used to print the Task to STDOUT.
				def track_to_array(track)
					# task = track.task
					
					# track_s = Array.new
					# track_s << ' Task: %s %s' % [task.short_id, task.name_s]
					# track_s << 'Track: %s %s' % [track.short_id, track.name]
					
					# duration_human = track.duration.to_human
					# track_s << '  Duration: %s' % [duration_human]
					
					# duration_man_days = track.duration.to_man_days
					# if duration_human != duration_man_days
					# 	track_s << '  Man Unit: %s' % [duration_man_days]
					# end
					
					# if track.begin_datetime
					# 	track_s << '  Begin: %s' % [track.begin_datetime_s]
					# end
					
					# if track.end_datetime
					# 	track_s << '  End:   %s' % [track.end_datetime_s]
					# end
					
					# status = track.status.colorized
					# track_s << '  Status: %s' % [status]
					# if track.message
					# 	track_s << '  Message: %s' % [track.message]
					# end
					
					# track_s << '  File path: %s' % [task.file_path]
					
					# track_s
					
					#track.to_detailed_array({:duration_man_days => true, :message => true})
					track.to_detailed_array
				end
				
				def check_task_id
					if @tracks_opt.count == 0
						raise TrackCommandError, 'No Task ID given.'
					end
					@tracks_opt.first
				end
				
				def check_track_id
					if @tracks_opt.count == 0
						raise TrackCommandError, 'No Track ID given.'
					end
					@tracks_opt.first
				end
				
				def check_opts_add
					# if @start_date_opt.nil? && @start_time_opt.nil? &&
					# 	@end_date_opt.nil? && @end_time_opt.nil? &&
					# 	@message_opt.nil? &&
					# 	@billed_opt.nil? && @unbilled_opt.nil?
						
					# 	raise TrackCommandError, "No option given. See 'timr track --help'."
					# end
					
					if @start_date_opt || @start_time_opt ||
						@end_date_opt || @end_time_opt
						
						if @start_date_opt.nil?
							raise TrackCommandError, 'Start Date must be given.'
						end
						if @start_time_opt.nil?
							raise TrackCommandError, 'Start Time must be given.'
						end
						
						if @end_date_opt.nil?
							raise TrackCommandError, 'End Date must be given.'
						end
						if @end_time_opt.nil?
							raise TrackCommandError, 'End Time must be given.'
						end
					end
				end
				
				def check_opts_set
					if @start_date_opt.nil? && @start_time_opt.nil? &&
						@end_date_opt.nil? && @end_time_opt.nil? &&
						@message_opt.nil? && @task_id_opt.nil? &&
						@billed_opt.nil? && @unbilled_opt.nil?
						
						raise TrackCommandError, "No option given. See 'timr track --help'."
					end
				end
				
				def help
					puts 'usage: timr track [show] [-t|--task] <track_id>...'
					puts '   or: timr track add [-m|--message <message>]'
					puts '                      [--start-date <YYYY-MM-DD> --start-time <HH:MM[:SS]>'
					puts '                        [--end-date <YYYY-MM-DD> --end-time <HH:MM[:SS]>]]'
					puts '                      [--billed|--unbilled] <task_id>'
					puts '   or: timr track set [-m|--message <message>]'
					puts '                      [--start-date <YYYY-MM-DD> --start-time <HH:MM[:SS]>]'
					puts '                      [--end-date <YYYY-MM-DD> --end-time <HH:MM[:SS]>]'
					puts '                      [-t|--task <task_id>] [--billed|--unbilled]'
					puts '                      <track_id>'
					puts '   or: timr track remove <track_id>...'
					puts '   or: timr track [-h|--help]'
					puts
					puts 'Show Options'
					puts "    -t, --task       Show Task of Track. Same as 'timr task <task_id>'."
					puts
					puts 'Add/Set Options'
					puts '    -m, --message                      Track Message. What have you done?'
					puts '    --sd, --start-date <YYYY-MM-DD>    Start Date'
					puts '    --st, --start-time <HH:MM[:SS]>    Start Time'
					puts '    --ed, --end-date <YYYY-MM-DD>      End Date'
					puts '    --et, --end-time <HH:MM[:SS]>      End Time'
					puts '    -b, --billed                       Mark Track as billed.'
					puts '    --unbilled                         Mark Track as unbilled.'
					puts
					puts 'Set Options'
					puts '    --task <task_id>                   Move Track to another Task.'
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
