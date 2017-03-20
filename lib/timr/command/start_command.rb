
require 'tempfile'

module TheFox
	module Timr
		
		# Start a new Track.
		class StartCommand < Command
			
			def initialize(argv = Array.new)
				super()
				
				@help_opt = false
				
				@name_opt = nil
				@description_opt = nil
				@date_opt = nil
				@time_opt = nil
				@message_opt = nil
				@edit_opt = false
				@id_opts = Array.new
				
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
					when '-e', '--edit'
						@edit_opt = true
					else
						if arg[0] == '-'
							raise ArgumentError, "Unknown argument '#{arg}'. See 'timr start --help'."
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
				
				if @edit_opt
					# Edit feature is still in alpha stage.
					unless ENV['EDITOR']
						raise 'EDITOR environment variable not set'
					end
					
					tmpfile = Tempfile.new('timr_start_message')
					tmpfile.write("\n")
					tmpfile.write("# This is a comment.\n")
					tmpfile.write("# The first line should be a sentence. Sentence have dots at the end.\n")
					tmpfile.write("# The second line should be empty, if you provide a more detailed\n")
					tmpfile.write("# description from on the third line. Like on Git.\n")
					tmpfile.close
					
					# @TODO Edit option: when a <track_id> is provided, you maybe want to edit
					# a copy of this track here. But this also means that the current work flow below
					# via @timr.start is not working here anymore. When no <track_id> is provided, edit
					# the current running track before (or after) it ended.
					
					system_s = '%s %s' % [ENV['EDITOR'], tmpfile.path]
					puts "start '#{system_s}'"
					system(system_s)
					
					tmpfile.open
					tmpfile_lines = tmpfile.read
					tmpfile.close
					
					@message_opt = tmpfile_lines.split("\n").map{ |row| row.strip }.select{ |row| row[0] != '#' }.join("\n")
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
				track = @timr.start(options)
				unless track
					raise 'Could not start a new Track.'
				end
				
				task = track.task
				unless task
					raise "Tack #{track.id} has no Task."
				end
				
				status = track.status.colorized
				
				puts ' Task: %s %s' % [task.short_id, task.name]
				puts 'Track: %s %s' % [track.short_id, track.title]
				puts '  Start: %s' % [track.begin_datetime_s]
				puts '  Status: %s' % [status]
				puts 'Stack: %s' % [TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')]
			end
			
			private
			
			def help
				puts 'usage: timr start [-n|--name <name>] [--desc|--description <description>]'
				puts '                  [[-d|--date <YYYY-MM-DD>] -t|--time <HH:MM[:SS]>]'
				puts '                  [-m|--message <message>] [<task_id> [<track_id>]]'
				puts '   or: timr start [-h|--help]'
				puts
				puts 'Task Options'
				#puts '    -i, --id           Task ID' # @TODO --id
				puts '    -n, --name                 Name of the Task.'
				puts '    --desc, --description      Description of the Task.'
				#puts '    -e, --estimation <HH:MM>' # @TODO --estimation
				puts
				puts 'Track Options'
				puts '    -m, --message              Track Message. What have you done?'
				puts '                               You can overwrite this on stop command.'
				# puts '    -e, --edit         Edit Track Message.'
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
			
		end # class StartCommand
	
	end # module Timr
end # module TheFox