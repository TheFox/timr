
require 'set'

module TheFox
	module Timr
		module Command
			
			# - Print informations about a specific [Track](rdoc-ref:TheFox::Timr::Model::Track).
			# - Add/remove a Track.
			# - Edit (set) a Track.
			# 
			# Man page: [timr-track(1)](../../../../man/timr-track.1.html)
			class TrackCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/timr-track.1'
				
				def initialize(argv = Array.new)
					super()
					
					@help_opt = false
					@show_opt = false
					@add_opt = false
					@remove_opt = false
					@set_opt = false
					
					@verbose_opt = false
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
						
						when '-v', '--verbose'
							@verbose_opt = true
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
							@tracks_opt << arg
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
					
					task_command_args = tasks.values
					
					if @verbose_opt
						task_command_args << '--verbose'
					end
					
					task_command = TaskCommand.new(task_command_args)
					task_command.run
				end
				
				def run_show
					options = Hash.new
					if @verbose_opt
						options[:full_id] = true
					end
					
					tracks = Array.new
					@tracks_opt.each do |track_id|
						track = @timr.get_track_by_id(track_id)
						unless track
							raise TrackCommandError, "Track for ID '#{track_id}' not found."
						end
						
						tracks << track.to_detailed_array(options)
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
					
					puts track.to_detailed_str
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
					puts track.to_detailed_str
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
						
						if @timr.stack.on_stack?(track)
							@timr.stack.changed
							@timr.stack.save_to_file
						end
					end
					
					task.save_to_file
					
					puts '--- NEW ---'
					puts track.to_detailed_str
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
					puts '                      [--start-date <date> --start-time <time>'
					puts '                        [--end-date <date> --end-time <time>]]'
					puts '                      [--billed|--unbilled] <id>|<task_id>'
					puts '   or: timr track set [-m|--message <message>]'
					puts '                      [--start-date <date> --start-time <time>]'
					puts '                      [--end-date <date> --end-time <time>]'
					puts '                      [-t|--task <id>|<task_id>] [--billed|--unbilled]'
					puts '                      <track_id>'
					puts '   or: timr track remove <track_id>...'
					puts '   or: timr track [-h|--help]'
					puts
					puts 'Show Options'
					puts "    -t, --task       Show Task of Track. Same as 'timr task <task_id>'."
					puts
					puts 'Add/Set Options'
					puts '    -m, --message <message>      Track Message. What have you done?'
					puts '    --sd, --start-date <date>    Start Date'
					puts '    --st, --start-time <time>    Start Time'
					puts '    --ed, --end-date <date>      End Date'
					puts '    --et, --end-time <time>      End Time'
					puts '    -b, --billed                 Mark Track as billed.'
					puts '    --unbilled                   Mark Track as unbilled.'
					puts
					puts 'Set Options'
					puts '    --task <id>|<task_id>        Move Track to another Task.'
					puts
					puts 'Start DateTime must be given when End DateTime is given. A Track cannot have a'
					puts 'End DateTime without a Start DateTime.'
					puts
					HelpCommand.print_man_units_help
					puts
					HelpCommand.print_datetime_help
					puts
				end
				
			end # class TrackCommand
			
		end # module Command
	end # module Timr
end # module TheFox
