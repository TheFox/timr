
require 'thefox-ext'

module TheFox
	module Timr
		module Command
			
			class StatusCommand < Command
				
				include TheFox::Timr::Error
				
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
							raise StatusCommandError, "Unknown argument '#{arg}'. See 'timr stop --help'."
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
					tracks = Array.new
					track_c = 0
					get_tracks.each do |track|
						track_c += 1
						
						task = track.task
						duration = track.duration.to_human
						
						status = track.status.colorized
						
						track_s = Array.new
						track_s << '--- #%d ---' % [track_c]
						track_s << ' Task: %s %s' % [task.short_id, task.name_s]
						track_s << 'Track: %s %s' % [track.short_id, track.title]
						track_s << '  Start: %s' % [track.begin_datetime_s]
						track_s << '  End:   %s' % [track.end_datetime_s || '--']
						track_s << '  Duration: %16s' % [duration]
						track_s << '  Status: %s' % [status]
						tracks << track_s
					end
					
					if tracks.count > 0
						puts tracks.map{ |track_s| track_s.join("\n") }.join("\n\n")
					else
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
					puts '    S        Status'
					puts '    START    Track Start Date'
					puts '    END      Track End Date'
					puts '    DUR      Track Duration'
					puts '    TASK     Task ID'
					puts '    TRACK    Track ID and Title.'
					puts
					puts 'Status'
					puts '    R    Running'
					puts '    S    Stopped'
					puts '    U    Unknown'
					puts '    -    Not started yet.'
					puts
				end
				
			end # class StatusCommand
			
		end # module Command
	end # module Timr
end # module TheFox
