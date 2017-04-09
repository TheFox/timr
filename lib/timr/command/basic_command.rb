
require 'pathname'

module TheFox
	module Timr
		module Command
			
			# Basic Class
			class BasicCommand
				
				include TheFox::Timr::Helper
				
				# Current Working Directory
				attr_accessor :cwd
				
				def initialize(argv = Array.new)
					@cwd = nil
					@timr = nil
				end
				
				# This is the actual execution of the Command.
				def run
					raise NotImplementedError
				end
				
				# Should be executed after `run` to gently save everything.
				def shutdown
					if @timr
						@timr.shutdown
					end
				end
				
				# All methods in this block are static.
				class << self
					
					include TheFox::Timr::Error
					
					# Creates a new Command instance for each command string.
					# 
					# For example, it returns a new StopCommand instance when `stop` String is provided by `argv` Array.
					# 
					# Primary used by `bin/timr`.
					def create_command_from_argv(argv)
						# -C <path>
						cwd_opt = Pathname.new("#{Dir.home}/.timr/defaultc").expand_path # Default Client
						
						command_name = nil
						command_argv = Array.new
						loop_c = 0
						while loop_c < 1024 && argv.length > 0
							loop_c += 1
							arg = argv.shift
							
							if command_name
								command_argv << arg
							else
								case arg
								when '-h', '--help', 'help'
									command_name = 'help'
								when '-V', '--version'
									command_name = 'version'
								when '-C'
									cwd_opt = Pathname.new(argv.shift).expand_path
								when '--install-basepath'
									timr_gem = Gem::Specification.find_by_name('timr')
									print timr_gem.gem_dir
									exit
								else
									if arg[0] == '-'
										raise CommandError, "Unknown argument '#{arg}'. See 'timr --help'."
									else
										command_name = arg
									end
								end
							end
						end
						
						command_class = get_command_class_by_name(command_name)
						command = command_class.new(command_argv)
						command.cwd = cwd_opt
						command
					end
					
					# Get the Class for each command string.
					def get_command_class_by_name(name)
						case name
						when 'help', '', nil
							command = HelpCommand
						when 'version'
							command = VersionCommand
						
						when 'status', 's'
							command = StatusCommand
						when 'start'
							command = StartCommand
						when 'stop'
							command = StopCommand
						when 'push'
							command = PushCommand
						when 'pop'
							command = PopCommand
						when 'continue', 'cont', 'c'
							command = ContinueCommand
						when 'pause', 'p'
							command = PauseCommand
						when 'log'
							command = LogCommand
						when 'task'
							command = TaskCommand
						when 'track'
							command = TrackCommand
						when 'report'
							command = ReportCommand
						else
							raise CommandError, "'%s' is not a timr command. See 'timr --help'." % [name]
						end
					end
					
				end
				
				private
				
				# Uses
				#   @timr
				#   @edit_opt
				#   @task_id_opt
				#   @track_id_opt
				def run_edit(task_id = nil, track_id = nil)
					task_id ||= @task_id_opt
					track_id ||= @track_id_opt
					
					if @timr && @edit_opt
						edit_text = Array.new
						
						if @message_opt
							edit_text << @message_opt.clone
						else
							# puts "get_track_by_task_id"
							track = @timr.get_track_by_task_id(task_id, track_id)
							# puts "TRACK: #{track}"
							if track && track.message
								edit_text << track.message.clone
							else
								edit_text << @message_opt.clone
							end
						end
						
						TerminalHelper.external_editor_help(edit_text)
						
						editor_message = TerminalHelper.run_external_editor(edit_text)
						# puts "msg: '#{editor_message}'"
						
						if editor_message.length > 0
							@message_opt = editor_message
						end
					end
				end
				
			end # class Command
			
		end # module Command
	end # module Timr
end # module TheFox
