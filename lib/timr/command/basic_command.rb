
require 'pathname'

module TheFox
	module Timr
		module Command
			
			# Basic Class
			class BasicCommand
				
				include TheFox::Timr::Error
				
				# Current Working Directory
				attr_accessor :cwd
				
				def initialize
					# puts "#{Time.now.to_ms} #{self.class} #{__method__}"
					
					@cwd = nil
					@timr = nil
				end
				
				def run
					raise NotImplementedError
				end
				
				def shutdown
					if @timr
						@timr.shutdown
					end
				end
				
				# All methods in this block are static.
				class << self
					
					# Creates a new Command instance for each command string.
					# 
					# For example, it returns a new StopCommand instance when `stop` String is provided by `argv` Array.
					# 
					# Used by `bin/timr`.
					def create_command_from_argv(argv)
						# optparser = SimpleOptParser.new
						
						help_opt = false # --help
						# optparser.register_option(['-h', '--help'])
						
						version_opt = false # --version
						# optparser.register_option(['-V', '--version'])
						
						# -C <path>
						cwd_opt = Pathname.new("#{Dir.home}/.timr/project").expand_path
						# optparser.register_option(['-C'], 1)
						
						# opts = optparser.parse(argv)
						# puts "opts '#{opts}'"
						# puts "opts unknown '#{optparser.unknown_options}'"
						
						command_name = nil
						command_argv = []
						loop_c = 0
						while loop_c < 1024 && argv.length > 0
							loop_c += 1
							arg = argv.shift
							#puts "arg: '#{arg}'"
							
							if command_name
								# puts "command_name already set"
								
								command_argv << arg
							else
								case arg
								when '-h', '--help', 'help'
									help_opt = true
								when '-V', '--version'
									version_opt = true
								when '-C'
									cwd_opt = Pathname.new(argv.shift).expand_path
									# puts "cwd_opt: #{cwd_opt}"
								else
									# puts "ELSE '#{arg[0]}'"
									if arg[0] == '-'
										raise CommandError, "Unknown argument '#{arg}'. See 'timr --help'."
									else
										# puts "set command_name"
										command_name = arg
									end
								end
							end
						end
						
						if help_opt
							command = HelpCommand.new
						elsif version_opt
							command = VersionCommand.new
						else
							case command_name
							when 'help'
								command = HelpCommand.new
							when 'status', 's'
								command = StatusCommand.new(command_argv)
							when 'start'
								command = StartCommand.new(command_argv)
							when 'stop'
								command = StopCommand.new(command_argv)
							when 'push'
								command = PushCommand.new(command_argv)
							when 'pop'
								command = PopCommand.new(command_argv)
							when 'continue', 'cont', 'c'
								command = ContinueCommand.new(command_argv)
							when 'pause', 'p'
								command = PauseCommand.new(command_argv)
							when 'log'
								command = LogCommand.new(command_argv)
							when 'task'
								command = TaskCommand.new(command_argv)
							when 'track'
								command = TrackCommand.new(command_argv)
							when 'report'
								command = ReportCommand.new(command_argv)
							else
								raise CommandError, "timr: '%s' is not a timr command. See 'timr --help'." % [command_name]
							end
						end
						
						command.cwd = cwd_opt
						command
					end
					
				end
				
			end # class Command
			
		end # module Command
	end # module Timr
end # module TheFox
