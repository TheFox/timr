
require 'thefox-ext'

module TheFox
	module Timr
		
		class StatusCommand < Command
			
			def initialize(argv = Array.new)
				#puts "argv '#{argv}'"
				super()
				
				@help_opt = false
				@full_opt = false
				@reverse_opt = false
				
				loop_c = 0 # Limit the loop.
				while loop_c < 1024 && argv.length > 0
					loop_c += 1
					arg = argv.shift
					
					case arg
					when '-h', '--help'
						@help_opt = true
					when '-f', '--full'
						@full_opt = true
					when '-r', '--reverse'
						@reverse_opt = true
					else
						raise ArgumentError, "Unknown argument '#{arg}'. See 'timr stop --help'."
					end
				end
			end
			
			def run
				if @help_opt
					help
					return
				end
				
				@timr = Timr.new(@cwd)
				
				# puts '----------'
				#puts 'STACK'
				if @full_opt
					print_full_table
				else
					print_small_table
				end
			end
			
			private
			
			def print_small_table
				table_has_rows = false
				
				table_options = {
					:headings => [
						{:format => '%2s', :label => '##'},
						{:format => '%1s', :label => 'S'},
						{:format => '%-5s', :label => 'START', :padding_left => ' '},
						{:format => '%-5s', :label => 'END'},
						{:format => '%8s', :label => 'DUR', :padding_right => ' '},
						{:format => '%-6s', :label => 'TASK', :padding_right => ' '},
						{:format => '%s', :label => 'TRACK'},
					],
				}
				table = Table.new(table_options)
				
				track_c = 0
				get_tracks.each do |track|
					track_c += 1
					table_has_rows = true
					
					task = track.task
					
					status = track.status.short_status
					duration = track.duration.to_human
					
					if track.begin_datetime
						begin_datetime_s = track.begin_datetime_s({:format => '%H:%M'})
					end
					
					if track.end_datetime
						end_datetime_s = track.end_datetime_s({:format => '%H:%M'})
					end
					
					table << [
						track_c,
						status,
						begin_datetime_s,
						end_datetime_s,
						duration,
						task.short_id,
						'%s %s' % [track.short_id, track.title(15)],
					]
				end
				
				if table_has_rows
					puts table
				else
					print_no_tracks
				end
			end
			
			def print_full_table
				table_has_rows = false
				
				track_c = 0
				get_tracks.each do |track|
					track_c += 1
					table_has_rows = true
					
					task = track.task
					duration = track.duration.to_human
					
					status = track.status.colorized
					
					puts '--- #%d ---' % [track_c]
					puts ' Task: %s %s' % [task.short_id, task.name]
					puts 'Track: %s %s' % [track.short_id, track.title]
					puts '  Start: %s' % [track.begin_datetime_s]
					puts '  End:   %s' % [track.end_datetime_s || '--']
					puts '  Duration: %16s' % [duration]
					puts '  Status: %s' % [status]
					puts
				end
				
				unless table_has_rows
					print_no_tracks
				end
			end
			
			def print_no_tracks
				puts 'There is no running Track.'
			end
			
			def get_tracks
				if @reverse_opt
					@timr.stack.tracks.reverse
				else
					@timr.stack.tracks
				end
			end
			
			def help
				puts 'usage: timr status [-h|--help] [-f|--full] [-r|--reverse]'
				puts
				puts 'Options'
				puts '    -f, --full       Show full status.'
				puts '    -r, --reverse    Reverse the list.'
				puts
				puts 'Columns'
				puts '    S        Status: R = Running, S = Stopped/Paused,' # P = Paused,
				puts '                     U = Unknown, - = Not started yet.'
				puts '    START    Track Start Date'
				puts '    END      Track End Date'
				puts '    DUR      Track Duration'
				puts '    TASK     Task ID'
				puts '    TRACK    Track ID and Title.'
				puts
			end
			
		end # class StatusCommand
	
	end # module Timr
end # module TheFox