
#require 'term/ansicolor'

module TheFox
	module Timr
		
		class TaskCommand < Command
			
			include Term::ANSIColor
			
			def initialize(argv = [])
				super()
				# puts "argv '#{argv}'"
				
				@help_opt = false
				@task_opt = Array.new
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					else
						if /[a-f0-9]+/i.match(arg)
							@task_opt << arg
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
				
				#unknown_tasks = Array.new
				tasks = Array.new
				@task_opt.each do |task_id|
					# begin
						task = @timr.get_task_by_id(task_id)
					# rescue Exception => e
					# 	unknown_tasks << task_id
					# 	next
					# end
					
					duration_human = task.duration.to_human
					duration_man_days = task.duration.to_man_days
					
					tracks = task.tracks
					tracks_count = task.tracks.count
					
					if tracks_count > 0
						first_track = tracks.sort_by{ |tid, t| t.begin_datetime }.to_h.values.first
						last_track  = tracks.sort_by{ |tid, t| t.end_datetime   }.to_h.values.last
						
						task_s = Array.new
						task_s << 'Task: %s %s' % [task.short_id, task.name]
						task_s << 'Tracks: %d' % [tracks_count]
						if duration_human == duration_man_days
							task_s << 'Duration: %s' % [task.duration.to_human]
						else
							task_s << 'Duration: %s' % [duration_human]
							task_s << 'Man Unit: %s' % [duration_man_days]
						end
						task_s << 'Begin Track: %s  %s' % [first_track.short_id, first_track.begin_datetime_s]
						task_s << 'End   Track: %s  %s' % [last_track.short_id, last_track.end_datetime_s]
						
						if task.description
							task_s << 'Description: %s' % [task.description]
						end
					end
					
					tasks << task_s
				end
				
				puts tasks.map{ |t| t.join("\n") }.join("\n\n")
				
				# if unknown_tasks.count > 0
				# 	puts "Unknown Task IDs: #{unknown_tasks.join(' ')}"
				# end
			end
			
			private
			
			def help
				puts 'usage: timr task <task_ids...>'
				puts '   or: timr task [-h|--help]'
			end
			
		end # class TaskCommand
	
	end # module Timr
end # module TheFox
