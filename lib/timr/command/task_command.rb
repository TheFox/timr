
require 'set'

module TheFox
	module Timr
		module Command
			
			# - Print informations about a specific [Task](rdoc-ref:TheFox::Timr::Model::Task).
			# - Add/remove a Task.
			# - Edit (set) a Task.
			# 
			# Man page: [timr-task(1)](../../../../man/timr-task.1.html)
			class TaskCommand < BasicCommand
				
				include TheFox::Timr::Model
				include TheFox::Timr::Helper
				include TheFox::Timr::Error
				
				# Path to man page.
				MAN_PATH = 'man/timr-task.1'
				
				def initialize(argv = Array.new)
					super()
					# puts "argv #{argv}"
					
					@help_opt = false
					@show_opt = false
					@add_opt = false
					@remove_opt = false
					@set_opt = false
					
					@verbose_opt = false
					@tracks_opt = false
					
					@foreign_id_opt = nil
					@unset_foreign_id_opt = nil
					@name_opt = nil
					@description_opt = nil
					@estimation_opt = nil
					@billed_opt = nil
					@unbilled_opt = nil
					
					@hourly_rate_opt = nil
					@unset_hourly_rate_opt = nil
					@has_flat_rate_opt = nil
					@unset_flat_rate_opt = nil
					
					# Holds Task instances.
					@tasks_opt = Set.new
					
					loop_c = 0 # Limit the loop.
					while loop_c < 1024 && argv.length > 0
						loop_c += 1
						arg = argv.shift
						
						case arg
						when '-h', '--help'
							@help_opt = true
						
						when '-v', '--verbose'
							@verbose_opt = true
						when '-t', '--tracks'
							@tracks_opt = true
						
						when '--id'
							@foreign_id_opt = argv.shift.strip
						when '--no-id'
							@unset_foreign_id_opt = true
						when '-n', '--name'
							@name_opt = argv.shift
						when '--desc', '--description', '-d' # -d not official
							@description_opt = argv.shift
						when '-e', '--est', '--estimation'
							@estimation_opt = argv.shift
							# puts "est: #{@estimation_opt}"
						when '-b', '--billed'
							@billed_opt = true
						when '--unbilled'
							@unbilled_opt = true
						
						when '-r', '--hourly-rate'
							@hourly_rate_opt = argv.shift
						when '--no-hourly-rate'
							@unset_hourly_rate_opt = true
						when '--fr', '--flat', '--flat-rate'
							@has_flat_rate_opt = true
						when '--no-flat', '--no-flat-rate'
							@unset_flat_rate_opt = true
						
						when 'show'
							@show_opt = true
						when 'add'
							@add_opt = true
						when 'remove'
							@remove_opt = true
						when 'set'
							@set_opt = true
						
						when Task
							@tasks_opt << arg
						else
							@tasks_opt << arg
						end
						
						# puts "argv #{argv}"
					end
					
					if @foreign_id_opt && @unset_foreign_id_opt
						raise TaskCommandError, 'Cannot use --id and --no-id.'
					end
					if @billed_opt && @unbilled_opt
						raise TaskCommandError, 'Cannot use --billed and --unbilled.'
					end
					if !@hourly_rate_opt.nil? && @unset_hourly_rate_opt
						raise TaskCommandError, 'Cannot use --hourly-rate and --no-hourly-rate.'
					end
					if @has_flat_rate_opt && @unset_flat_rate_opt
						raise TaskCommandError, 'Cannot use --flat-rate and --no-flat-rate.'
					end
				end
				
				# See BasicCommand#run.
				def run
					if @help_opt
						help
						return
					end
					
					@timr = Timr.new(@cwd)
					
					if @add_opt
						run_add
					elsif @remove_opt
						run_remove
					elsif @set_opt
						run_set
					else
						if @tasks_opt.count == 0
							run_show_all
						else
							run_show
						end
					end
				end
				
				private
				
				# Uses TheFox::Timr::Timr.add_task.
				def run_add
					options = {
						:foreign_id => @foreign_id_opt,
						:name => @name_opt,
						:description => @description_opt,
						:estimation => @estimation_opt,
					}
					task = @timr.add_task(options)
					
					puts task.to_detailed_str
				end
				
				def run_remove
					@tasks_opt.each do |task_id|
						task = @timr.remove_task({:task_id => task_id})
						
						tracks_s = TranslationHelper.pluralize(@timr.stack.tracks.count, 'track', 'tracks')
						puts 'Deleted Task %s (%s).' % [task.short_id, tracks_s]
					end
				end
				
				def run_set
					if @tasks_opt.count == 0
						raise TaskCommandError, 'No Task ID given.'
					end
					task_id = @tasks_opt.first
					
					# @TODO run_set unit test
					if @foreign_id_opt.nil? && @unset_foreign_id_opt.nil? && \
						@name_opt.nil? && @description_opt.nil? && \
						@estimation_opt.nil? && \
						@billed_opt.nil? && @unbilled_opt.nil? && \
						@hourly_rate_opt.nil? && @unset_hourly_rate_opt.nil? && \
						@has_flat_rate_opt.nil? && @unset_flat_rate_opt.nil?
						
						raise TaskCommandError, "No option given. See 'time task -h'."
					end
					
					task = @timr.get_task_by_id(task_id)
					
					puts '--- OLD ---'
					puts task.to_detailed_str
					puts
					
					if @foreign_id_opt && task.foreign_id != @foreign_id_opt
						@timr.foreign_id_db.remove_task(task)
						
						# Throws exception when Foreign ID already exists in DB.
						# Break before Task save.
						@timr.foreign_id_db.add_task(task, @foreign_id_opt)
						@timr.foreign_id_db.save_to_file
					end
					if @unset_foreign_id_opt
						@timr.foreign_id_db.remove_task(task)
						@timr.foreign_id_db.save_to_file
					end
					if @name_opt
						task.name = @name_opt
					end
					if @description_opt
						task.description = @description_opt
					end
					if @estimation_opt
						task.estimation = @estimation_opt
					end
					if @billed_opt || @unbilled_opt
						if @billed_opt
							task.is_billed = true
						else
							task.is_billed = false
						end
					end
					if @hourly_rate_opt
						task.hourly_rate = @hourly_rate_opt
					end
					if @unset_hourly_rate_opt
						task.hourly_rate = nil
					end
					if @has_flat_rate_opt
						task.has_flat_rate = true
					end
					if @unset_flat_rate_opt
						task.has_flat_rate = false
					end
					
					task.save_to_file
					
					puts '--- NEW ---'
					puts task.to_detailed_str
				end
				
				def run_show
					options = Hash.new
					if @verbose_opt
						options[:full_id] = true
					end
					
					tasks = Array.new
					@tasks_opt.each do |task_id_or_instance|
						if task_id_or_instance.is_a?(Task)
							task = task_id_or_instance
						else
							task = @timr.get_task_by_id(task_id_or_instance)
						end
						
						tasks << task.to_detailed_array(options)
					end
					
					if tasks.count > 0
						puts tasks.map{ |t| t.join("\n") }.join("\n\n")
					end
				end
				
				def run_show_all
					@timr.tasks.each do |task_id, task|
						full_id = @verbose_opt ? task.id : task.short_id
						
						if task.foreign_id
							puts '%s %s %s' % [full_id, task.foreign_id, task.name_s]
						else
							puts '%s - %s' % [full_id, task.name_s]
						end
					end
				end
				
				def help
					puts 'usage: timr task [show] [[-t|--tracks] <id>|<task_id>...]'
					puts '   or: timr task add [--id <str>] [-n|--name <name>] [--description <str>]'
					puts '                     [--estimation <time>] [--billed|--unbilled]'
					puts '                     [--hourly-rate <float>] [--no-hourly-rate]'
					puts '                     [--flat-rate|--no-flat-rate]'
					puts '   or: timr task set [--id <str>] [-n|--name <name>] [--description <str>]'
					puts '                     [--estimation <time>] [--billed|--unbilled]'
					puts '                     [--hourly-rate <float>] [--no-hourly-rate]'
					puts '                     [--flat-rate|--no-flat-rate]'
					puts '                     <id>|<task_id>'
					puts '   or: timr task remove <id>|<task_id>...'
					puts '   or: timr task [-h|--help]'
					puts
					puts 'Subcommands'
					puts '    show      Default command. When no Task ID is given print all Tasks.'
					puts '    add       Add a new Task without starting it.'
					puts '    remove    Remove an existing Task.'
					puts '    set       Edit an existing Task.'
					puts
					puts 'Show Options'
					puts '    -t, --tracks             Show a list of Track IDs for each Task.'
					puts
					puts 'Add/Set Options'
					puts '    --id <str>                        Your ID to identify the Task.'
					puts '    -n, --name <name>                 Task Name.'
					puts '    --desc, --description <str>       Task Description.'
					puts '    -e, --est, --estimation <time>    Task Estimation. See details below.'
					puts '    -b, --billed                      Mark Task as billed.'
					puts '    --unbilled                        Mark Task as unbilled.'
					puts '    -r, --hourly-rate <float>         Set the Hourly Rate.'
					puts '    --no-hourly-rate                  Unset Hourly Rate.'
					puts '    --fr, --flat-rate, --flat         Has Task a Flat Rate?'
					puts '    --no-flat-rate, --no-flat         Unset Flat Rate.'
					puts
					HelpCommand.print_man_units_help
					puts
					HelpCommand.print_estimation_help(true)
					puts
					puts 'Billed/Unbilled'
					puts '    If a whole Task gets billed/unbilled all Tracks are changed to'
					puts "    billed/unbilled. Each Track has a flag 'is_billed'."
					puts
				end
				
			end # class TaskCommand
			
		end # module Command
	end # module Timr
end # module TheFox
