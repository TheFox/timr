
module TheFox
	module Timr
		
		# Print informations about a Track.
		class TrackCommand < Command
			
			def initialize(argv = [])
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				@tracks_opt = Set.new
				@task_opt = false
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-t', '--task'
						@task_opt = true
					else
						if /[a-f0-9]+/i.match(arg)
							@tracks_opt << arg
						else
							raise ArgumentError, "Unknown argument '#{arg}'. See 'timr track --help'."
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
				else
					run_normal
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
			
			def run_normal
				tracks = Array.new
				@tracks_opt.each do |track_id|
					track = @timr.get_track_by_id(track_id)
					
					duration_human = track.duration.to_human
					duration_man_days = track.duration.to_man_days
					status = track.status.colorized
					task = track.task
					
					track_s = Array.new
					track_s << ' Task: %s %s' % [task.short_id, task.name]
					track_s << 'Track: %s %s' % [track.short_id, track.name]
					
					track_s << '  Duration: %s' % [duration_human]
					if duration_human != duration_man_days
						track_s << '  Man Unit: %s' % [duration_man_days]
					end
					
					track_s << '  Begin: %s' % [track.begin_datetime_s]
					if track.end_datetime
						track_s << '  End:   %s' % [track.end_datetime_s]
					end
					
					track_s << '  Status: %s' % [status]
					if track.message
						track_s << '  Message: %s' % [track.message]
					end
					tracks << track_s
				end
				
				if tracks.count > 0
					puts tracks.map{ |t| t.join("\n") }.join("\n\n")
				end
			end
			
			def help
				puts 'usage: timr track [-t|--task] <track_ids...>'
				puts '   or: timr track [-h|--help]'
				puts
				puts 'Options'
				puts "    -t, --task    Show Task of Track. Same as 'timr task <task_id>'."
				puts
				puts 'Man Unit: 8 hours are 1 man-day.'
				puts '          5 man-days are 1 man-week, and so on.'
				puts
			end
			
		end # class TrackCommand
	
	end # module Timr
end # module TheFox
