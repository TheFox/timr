
require 'term/ansicolor'

module TheFox
	module Timr
		
		class PushCommand < Command
			
			include Term::ANSIColor
			
			def initialize(argv = [])
				super()
				
				@help_opt = false
				
				@name_opt = nil
				@description_opt = nil
				@date_opt = nil
				@time_opt = nil
				@message_opt = nil
				# @edit_opt = false
				@id_opts = []
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-n', '--name'
						@name_opt = argv.shift
					when '--desc', '--description'
						@description_opt = argv.shift
					when '-d', '--date'
						@date_opt = argv.shift
					when '-t', '--time'
						@time_opt = argv.shift
					when '-m', '--message'
						@message_opt = argv.shift
					# when '-e', '--edit'
					# 	@edit_opt = true
					else
						if arg[0] == '-'
							raise ArgumentError, "Unknown argument '#{arg}'. See 'timr push --help'."
						else
							if @id_opts.length < 2
								@id_opts << arg
							end
						end
					end
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				options = {
					:name => @name_opt,
					:description => @description_opt,
					:date => @date_opt,
					:time => @time_opt,
					:message => @message_opt,
					:task_id => @id_opts.shift,
					:track_id => @id_opts.shift,
				}
				
				@timr = Timr.new(@cwd)
				track = @timr.push(options)
				unless track
					raise 'Could not start a new Track.'
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				status = green(track.long_status)
				
				puts '----------'
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  Status: %s' % [status]
				puts 'Stack: %s' % [TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')]
			end
			
			private
			
			def help
				puts 'usage: timr push [-n|--name <name>] [--desc|--description <description>]'
				puts '                  [[-d|--date <YYYY-MM-DD>] -t|--time <HH:MM[:SS]>]'
				puts '                  [-m|--message <message>] [<task_id> [<track_id>]]'
				puts '   or: timr push [-h|--help]'
				puts
				puts 'Task Options'
				puts '    -n, --name                 Name of the Task.'
				puts '    --desc, --description      Description of the Task.'
				puts
				puts 'Track Options'
				puts '    -m, --message              Track Message. What have you done?'
				puts '                               You can overwrite this on stop command.'
				puts '    -d, --date <YYYY-MM-DD>    Start Date. Default: today'
				puts '    -t, --time <HH:MM[:SS]>    Start Time. Default: now'
				puts
				puts 'Arguments'
				puts '    <task_id>     Task ID (SHA1 Hash)'
				puts '                  If not specified a new Task will be created.'
				puts
				puts '    <track_id>    Track ID (SHA1 Hash)'
				puts '                  If specified a new Track with the same'
				puts '                  Message will be created.'
				puts
			end
			
		end # class PushCommand
	
	end # module Timr
end # module TheFox
