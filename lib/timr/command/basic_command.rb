
require 'pathname'
require 'pp' # @TODO remove pp

module TheFox
	module Timr
		module Command
			
			# Basic Class
			class BasicCommand
				
				# Current Working Directory
				attr_accessor :cwd
				
				def initialize(argv = Array.new)
					# puts "#{Time.now.to_ms} #{self.class} #{__method__}" # @TODO remove
					# puts "argv #{argv}" # @TODO remove
					
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
									# puts "cwd_opt: #{cwd_opt}" # @TODO remove
								when '--install-basepath'
									# puts Pathname.new($0).expand_path.to_s
									# puts Pathname.new($0).expand_path.parent.to_s
									# puts Pathname.new($0).expand_path.parent.parent.to_s
									# puts
									# puts Pathname.new($0).to_s
									# puts Pathname.new($0).parent.to_s
									# puts Pathname.new($0).parent.parent.to_s
									# puts
									
									# puts Pathname.new(__FILE__).expand_path.to_s
									# puts Pathname.new(__FILE__).expand_path.parent.to_s
									# puts Pathname.new(__FILE__).expand_path.parent.parent.to_s
									# puts
									# puts Pathname.new(__FILE__).to_s
									# puts Pathname.new(__FILE__).parent.to_s
									# puts Pathname.new(__FILE__).parent.parent.to_s
									# puts
									
									#print Pathname.new($0).expand_path.parent.parent.to_s
									timr_gem = Gem::Specification.find_by_name('timr')
									print timr_gem.gem_dir
									#pp timr_gem.spec_dir
									exit
								else
									# puts "ELSE '#{arg[0]}'"
									if arg[0] == '-'
										raise CommandError, "Unknown argument '#{arg}'. See 'timr --help'."
									else
										# puts "set command_name" # @TODO remove
										command_name = arg
									end
								end
							end
						end
						
						puts "command_name: '#{command_name}'"
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
				
			end # class Command
			
		end # module Command
	end # module Timr
end # module TheFox
