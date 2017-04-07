
module TheFox
	module Timr
		module Command
			
			# - Print informations about a specific [Task](rdoc-ref:TheFox::Timr::Model::Task).
			# - Add/remove a Task.
			# - Edit (set) a Task.
			class TaskCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				MAN_PATH = 'man/task.1'
				
				def initialize(argv = Array.new)
					super()
					# puts "argv #{argv.frozen?} '#{argv}'"
					
					@help_opt = false
					@show_opt = false
					@add_opt = false
					@remove_opt = false
					@set_opt = false
					
					@tracks_opt = false
					@name_opt = nil
					@description_opt = nil
					@estimation_opt = nil
					@billed_opt = nil
					@unbilled_opt = nil
					
					@hourly_rate_opt = nil
					@unset_hourly_rate_opt = nil
					@has_flat_rate_opt = nil
					@unset_flat_rate_opt = nil
					
					# Holds Task instances.
					@tasks_opt = Set.new
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						when '-t', '--tracks'
							@tracks_opt = true
						when '-n', '--name'
							@name_opt = argv.shift
							#puts "name: #{@name_opt.class} #{@name_opt.is_digit?}" # @TODO remove
						when '--desc', '--description', '-d' # -d not official
							@description_opt = argv.shift
						when '-e', '--est', '--estimation'
							@estimation_opt = argv.shift
						when '-b', '--billed'
							@billed_opt = true
						when '--unbilled'
							@unbilled_opt = true
						
						when '-r', '--hourly-rate'
							@hourly_rate_opt = argv.shift
						when '--no-hourly-rate'
							@unset_hourly_rate_opt = true
						when '--fr', '--flat', '--flat-rate'
							@has_flat_rate_opt = true
						when '--no-flat', '--no-flat-rate'
							@unset_flat_rate_opt = true
						
						when 'show'
							@show_opt = true
						when 'add'
							@add_opt = true
						when 'remove'
							@remove_opt = true
						when 'set'
							@set_opt = true
						
						when Task
							@tasks_opt << arg
						else
							# puts 'opt else' # @TODO remove
							if /^[a-f0-9]{4,40}$/i.match(arg)
								# puts 'collect tasks' # @TODO remove
								@tasks_opt << arg
							else
								raise TaskCommandError, "Unknown argument '#{arg}'. See 'timr task --help'."
							end
						end
					end
					
					if @billed_opt && @unbilled_opt
						raise TaskCommandError, 'Cannot use --billed and --unbilled.'
					end
					if !@hourly_rate_opt.nil? && @unset_hourly_rate_opt
						raise TaskCommandError, 'Cannot use --hourly-rate and --no-hourly-rate.'
					end
					if @has_flat_rate_opt && @unset_flat_rate_opt
						raise TaskCommandError, 'Cannot use --flat-rate and --no-flat-rate.'
					end
					
					# pp @tasks_opt
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					if @add_opt
						run_add
					elsif @remove_opt
						run_remove
					elsif @set_opt
						run_set
					else
						if @tasks_opt.count == 0
							run_show_all
						else
							run_show
						end
					end
				end
				
				private
				
				# Uses TheFox::Timr::Timr.add_task.
				def run_add
					options = {
						:name => @name_opt,
						:description => @description_opt,
						:estimation => @estimation_opt,
					}
					task = @timr.add_task(options)
					
					puts task.to_compact_str
				end
				
				def run_remove
					@tasks_opt.each do |task_id|
						task = @timr.remove_task({:task_id => task_id})
						
						tracks_s = TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')
						puts 'Deleted Task %s (%s).' % [task.short_id, tracks_s]
					end
				end
				
				def run_set
					if @tasks_opt.count == 0
						raise TaskCommandError, 'No Task ID given.'
					end
					task_id = @tasks_opt.first
					
					if @name_opt.nil? && @description_opt.nil? &&
						@estimation_opt.nil? &&
						@billed_opt.nil? && @unbilled_opt.nil? &&
						@hourly_rate_opt.nil? && @unset_hourly_rate_opt.nil? &&
						@has_flat_rate_opt.nil? && @unset_flat_rate_opt.nil?
						
						raise TaskCommandError, "No option given. See 'time task -h'."
					end
					
					# puts "@name_opt #{@name_opt.nil?}"
					# puts "@description_opt #{@description_opt.nil?}"
					# puts "@estimation_opt #{@estimation_opt.nil?}"
					# puts "@billed_opt #{@billed_opt.nil?}"
					# puts "@unbilled_opt #{@unbilled_opt.nil?}"
					# puts "@hourly_rate_opt #{@hourly_rate_opt.nil?}"
					# puts "@unset_hourly_rate_opt #{@unset_hourly_rate_opt.nil?}"
					# puts "@has_flat_rate_opt #{@has_flat_rate_opt.nil?}"
					# puts "@unset_flat_rate_opt #{@unset_flat_rate_opt.nil?}"
					
					task = @timr.get_task_by_id(task_id)
					
					puts '--- OLD ---'
					puts task.to_detailed_str
					puts
					
					if @name_opt
						task.name = @name_opt
					end
					if @description_opt
						task.description = @description_opt
					end
					if @estimation_opt
						task.estimation = @estimation_opt
					end
					if @billed_opt || @unbilled_opt
						if @billed_opt
							task.is_billed = true
						else
							task.is_billed = false
						end
					end
					if @hourly_rate_opt
						task.hourly_rate = @hourly_rate_opt
					end
					if @unset_hourly_rate_opt
						task.hourly_rate = nil
					end
					if @has_flat_rate_opt
						task.has_flat_rate = true
					end
					if @unset_flat_rate_opt
						task.has_flat_rate = false
					end
					
					task.save_to_file
					
					puts '--- NEW ---'
					puts task.to_detailed_str
				end
				
				def run_show
					tasks = Array.new
					@tasks_opt.each do |task_id_or_instance|
						if task_id_or_instance.is_a?(Task)
							task = task_id_or_instance
						else
							task = @timr.get_task_by_id(task_id_or_instance)
						end
						
						# tasks << task_to_array(task)
						tasks << task.to_detailed_array
					end
					
					if tasks.count > 0
						puts tasks.map{ |t| t.join("\n") }.join("\n\n")
					end
				end
				
				def run_show_all
					@timr.tasks.each do |task_id, task|
						puts '%s %s' % [task.short_id, task.name_s]
					end
				end
				
				# Is used to print the Task to STDOUT.
				# def task_to_array(task)
				# 	task_s = Array.new
				# 	task_s << 'Task: %s %s' % [task.short_id, task.name]
					
				# 	duration_human = task.duration.to_human
				# 	task_s << '  Duration: %s' % [duration_human]
					
				# 	duration_man_days = task.duration.to_man_days
				# 	if duration_human != duration_man_days
				# 		task_s << '  Man Unit: %s' % [duration_man_days]
				# 	end
					
				# 	tracks = task.tracks
				# 	first_track = tracks
				# 		.select{ |track_id, track| track.begin_datetime }
				# 		.sort_by{ |track_id, track| track.begin_datetime }
				# 		.to_h
				# 		.values
				# 		.first
				# 	if first_track
				# 		task_s << '  Begin Track: %s  %s' % [first_track.short_id, first_track.begin_datetime_s]
				# 	end
					
				# 	last_track = tracks
				# 		.select{ |track_id, track| track.end_datetime }
				# 		.sort_by{ |track_id, track| track.end_datetime }
				# 		.to_h
				# 		.values
				# 		.last
				# 	if last_track
				# 		task_s << '  End   Track: %s  %s' % [last_track.short_id, last_track.end_datetime_s]
				# 	end
					
				# 	status = task.status.colorized
				# 	task_s << '  Status: %s' % [status]
					
				# 	tracks_count = tracks.count
				# 	task_s << '  Tracks: %d' % [tracks_count]
					
				# 	if tracks_count > 0 && @tracks_opt # --tracks
				# 		task_s << '  Track IDs: %s' % [tracks.map{ |track_id, track| track.short_id }.join(' ')]
				# 	end
					
				# 	if task.description
				# 		task_s << '  Description: %s' % [task.description]
				# 	end
					
				# 	task_s << '  File path: %s' % [task.file_path]
					
				# 	task_s
				# end
				
				def help
					puts 'usage: timr task [show] [[-t|--tracks] <task_id>...]'
					puts '   or: timr task add [-n|--name <name>] [--description <str>]'
					puts '                     [--estimation <time>] [--billed|--unbilled]'
					puts '                     [--hourly-rate <value>] [--no-hourly-rate]'
					puts '                     [--flat-rate|--no-flat-rate]'
					puts '   or: timr task set [-n|--name <name>] [--description <str>]'
					puts '                     [--estimation <time>] [--billed|--unbilled]'
					puts '                     [--flat-rate|--no-flat-rate]'
					puts '                     <task_id>'
					puts '   or: timr task remove <task_id>...'
					puts '   or: timr task [-h|--help]'
					puts
					puts 'Subcommands'
					puts '    show      Default command. When no Task ID is given print all Tasks.'
					puts '    add       Add a new Task without starting it.'
					puts '    remove    Remove an existing Task.'
					puts '    set       Edit an existing Task.'
					puts
					puts 'Show Options'
					puts '    -t, --tracks             Show a list of Track IDs for each Task.'
					puts
					puts 'Add/Set Options'
					puts '    -n, --name <name>                 Name of the Task.'
					puts '    --desc, --description <str>       Description of the Task.'
					puts '    -e, --est, --estimation <time>    Estimation of the Task. See details below.'
					puts '    -b, --billed                      Mark Task as billed.'
					puts '    --unbilled                        Mark Task as unbilled.'
					puts '    -r, --hourly-rate <value>         Set the Hourly Rate for this Task.'
					puts '    --no-hourly-rate                  Unset Hourly Rate.'
					puts '    --fr, --flat-rate, --flat         Has Task a Flat Rate?'
					puts '    --no-flat-rate, --no-flat         Unset Flat Rate.'
					puts
					puts 'Man Unit: 8 hours are 1 man-day.'
					puts '          5 man-days are 1 man-week, and so on.'
					puts
					puts 'Estimation'
					puts '  Estimation is parsed by chronic_duration.'
					puts '  Examples:'
					puts "      -e 2:10:5           # Sets Estimation to 2h 10m 5s."
					puts "      -e '2h 10m 5s'      # Sets Estimation to 2h 10m 5s."
					puts
					puts "  Use '+' or '-' to calculate with Estimation Times:"
					puts "      -e '-45m'           # Subtracts 45 minutes from the original Estimation."
					puts "      -e '+1h 30m'        # Adds 1 hour 30 minutes to the original Estimation."
					puts
					puts '  See chronic_duration for more examples.'
					puts '  https://github.com/henrypoydar/chronic_duration'
					puts
					puts 'Billed/Unbilled'
					puts '  If a whole Task gets billed/unbilled all Tracks are changed to'
					puts "  billed/unbilled. Each Track has a flag 'is_billed'."
					puts
				end
				
			end # class TaskCommand
			
		end # module Command
	end # module Timr
end # module TheFox
