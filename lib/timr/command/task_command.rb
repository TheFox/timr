
module TheFox
	module Timr
		
		# Print informations about a Task.
		class TaskCommand < Command
			
			def initialize(argv = Array.new)
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				@tasks_opt = Set.new
				@tracks_opt = false
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-t', '--tracks'
						@tracks_opt = true
					when Task
						@tasks_opt << arg
					else
						if /[a-f0-9]+/i.match(arg)
							@tasks_opt << arg
						else
							raise ArgumentError, "Unknown argument '#{arg}'. See 'timr task --help'."
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
				
				tasks = Array.new
				@tasks_opt.each do |task_id_or_instance|
					if task_id_or_instance.is_a?(Task)
						task = task_id_or_instance
					else
						task = @timr.get_task_by_id(task_id_or_instance)
					end
					
					duration_human = task.duration.to_human
					duration_man_days = task.duration.to_man_days
					
					tracks = task.tracks
					tracks_count = task.tracks.count
					
					status = task.status.colorized
					
					if tracks_count > 0
						first_track = tracks.sort_by{ |track_id, track| track.begin_datetime }.to_h.values.first
						last_track  = tracks.sort_by{ |track_id, track| track.end_datetime   }.to_h.values.last
						
						task_s = Array.new
						task_s << 'Task: %s %s' % [task.short_id, task.name]
						
						task_s << '  Duration: %s' % [duration_human]
						if duration_human != duration_man_days
							task_s << '  Man Unit: %s' % [duration_man_days]
						end
						
						task_s << '  Begin Track: %s  %s' % [first_track.short_id, first_track.begin_datetime_s]
						task_s << '  End   Track: %s  %s' % [last_track.short_id, last_track.end_datetime_s]
						
						task_s << '  Status: %s' % [status]
						
						task_s << '  Tracks: %d' % [tracks_count]
						if @tracks_opt # --tracks
							task_s << '  Track IDs: %s' % [tracks.map{ |track_id, track| track.short_id }.join(' ')]
						end
						
						if task.description
							task_s << '  Description: %s' % [task.description]
						end
						
						tasks << task_s
					end
				end
				
				if tasks.count > 0
					puts tasks.map{ |t| t.join("\n") }.join("\n\n")
				end
			end
			
			private
			
			def help
				puts 'usage: timr task <task_ids...>'
				puts '   or: timr task [-h|--help]'
				puts
				puts 'Options'
				puts '    -t, --tracks    Show a list of Track IDs for each Task.'
				puts
				puts 'Man Unit: 8 hours are 1 man-day.'
				puts '          5 man-days are 1 man-week, and so on.'
				puts
			end
			
		end # class TaskCommand
	
	end # module Timr
end # module TheFox
