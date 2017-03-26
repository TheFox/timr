
module TheFox
	module Timr
		
		# Print informations about a Task.
		class TaskCommand < Command
			
			def initialize(argv = Array.new)
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				@show_opt = false
				@add_opt = false
				@remove_opt = false
				
				@tracks_opt = false
				@name_opt = nil
				@description_opt = nil
				
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
					when '--desc', '--description', '-d' # -d not official
						@description_opt = argv.shift
					when 'show'
						@show_opt = true
					when 'add'
						@add_opt = true
					when 'remove'
						@remove_opt = true
					when Task
						@tasks_opt << arg
					else
						puts 'opt else' # @TODO remove
						if /[a-f0-9]+/i.match(arg)
							puts 'collect tasks' # @TODO remove
							@tasks_opt << arg
						else
							raise ArgumentError, "Unknown argument '#{arg}'. See 'timr task --help'."
						end
					end
				end
				
				# pp @tasks_opt
			end
			
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
				else
					if @tasks_opt.count == 0
						run_show_all
					else
						run_show
					end
				end
			end
			
			private
			
			def run_add
				options = {
					:name => @name_opt,
					:description => @description_opt,
				}
				task = @timr.add_task(options)
				
				task_s = Array.new
				task_s << 'Task: %s %s' % [task.short_id, task.name]
				if task.description
					task_s << 'Description: %s' % [task.description]
				end
				
				if task_s.count > 0
					puts task_s.join("\n")
				end
			end
			
			def run_remove
				@tasks_opt.each do |task_id|
					task = @timr.remove_task({:task_id => task_id})
					
					tracks_s = TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')
					puts 'Deleted task %s (%s).' % [task.short_id, tracks_s]
				end
			end
			
			def run_show
				tasks = Array.new
				@tasks_opt.each do |task_id_or_instance|
					if task_id_or_instance.is_a?(Task)
						task = task_id_or_instance
					else
						task = @timr.get_task_by_id(task_id_or_instance)
					end
					
					tasks << task_to_array(task)
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
			def task_to_array(task)
				task_s = Array.new
				task_s << 'Task: %s %s' % [task.short_id, task.name]
				
				duration_human = task.duration.to_human
				task_s << '  Duration: %s' % [duration_human]
				
				duration_man_days = task.duration.to_man_days
				if duration_human != duration_man_days
					task_s << '  Man Unit: %s' % [duration_man_days]
				end
				
				tracks = task.tracks
				first_track = tracks
					.select{ |track_id, track| track.begin_datetime }
					.sort_by{ |track_id, track| track.begin_datetime }
					.to_h
					.values
					.first
				if first_track
					task_s << '  Begin Track: %s  %s' % [first_track.short_id, first_track.begin_datetime_s]
				end
				
				last_track = tracks
					.select{ |track_id, track| track.end_datetime }
					.sort_by{ |track_id, track| track.end_datetime }
					.to_h
					.values
					.last
				if last_track
					task_s << '  End   Track: %s  %s' % [last_track.short_id, last_track.end_datetime_s]
				end
				
				status = task.status.colorized
				task_s << '  Status: %s' % [status]
				
				tracks_count = tracks.count
				task_s << '  Tracks: %d' % [tracks_count]
				
				if tracks_count > 0 && @tracks_opt # --tracks
					task_s << '  Track IDs: %s' % [tracks.map{ |track_id, track| track.short_id }.join(' ')]
				end
				
				if task.description
					task_s << '  Description: %s' % [task.description]
				end
				
				task_s << '  File path: %s' % [task.file_path]
				
				task_s
			end
			
			def help
				puts 'usage: timr task [show] [[-t|--tracks] <task_ids...>]'
				puts 'usage: timr task add [-n|--name <name>] [--description <str>]'
				puts '   or: timr task [-h|--help]'
				puts
				puts 'Subcommands'
				puts '    show      Default command. When no Task ID is given print all Tasks.'
				puts '    add       Add a new Task without starting it.'
				puts '    remove    Remove an existing Task.'
				puts
				puts 'Show Options'
				puts '    -t, --tracks             Show a list of Track IDs for each Task.'
				puts
				puts 'Add Options'
				puts '    -n, --name <name>              Name of the Task.'
				puts '    --desc, --description <str>    Description of the Task.'
				puts
				puts 'Man Unit: 8 hours are 1 man-day.'
				puts '          5 man-days are 1 man-week, and so on.'
				puts
			end
			
		end # class TaskCommand
	
	end # module Timr
end # module TheFox
