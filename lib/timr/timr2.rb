
require 'fileutils'
require 'yaml/store'
require 'pp'

module TheFox
	module Timr
		
		class Timr < TheFox::TermKit::CursesApp
			
			include TheFox::TermKit
			
			def initialize(options = {})
				super()
				
				#puts "Timr initialize: #{self.class}"
				
				@options = options
				@config = {
					'clock' => {
						'default' => '%F %R',
						'large' => '%F %T',
						'short' => '%R',
					},
				}
				
				#pp @options
				
				@base_dir_path = @options['base_dir_path']
				@base_dir_name = File.basename(@base_dir_path)
				@data_dir_path = File.expand_path('data', @base_dir_path)
				@config_path = @options['config_path']
				
				#puts "Timr base:   #{@base_dir_path}"
				#puts "Timr name:   #{@base_dir_name}"
				#puts "Timr data:   #{@data_dir_path}"
				#puts "Timr config: #{@config_path}"
				
				config_read
				init_dirs
				
				#puts 'Timr init task manager'
				@task_manager = TaskManager.new(@data_dir_path)
				@task_manager.load
				
				#puts "#{@task_manager.class}"
				
				#@containerController = ContainerController.new(self)
				#active_controller(@containerController)
				
				@appController = AppController.new(self)
				#@timelineViewController = TimelineViewController.new(self)
				#@tasksViewController = TasksViewController.new(self)
				@helpViewController = HelpViewController.new
				@helpViewController.app = self
				
				set_app_controller(@appController)
				set_active_controller(@helpViewController)
			end
			
			private
			
			def app_will_terminate
				if !@task_manager.nil?
					@task_manager.close
				end
			end
			
			def config_read
				begin
					content = YAML::load_file(@config_path)
					@config.merge_recursive!(content)
				rescue Exception # => e
					#puts "Task Manager WARNING: #{e}"
				end
			end
			
			def init_dirs
				if !Dir.exist?(@base_dir_path)
					FileUtils.mkdir_p(@base_dir_path)
				end
				if !Dir.exist?(@data_dir_path)
					FileUtils.mkdir_p(@data_dir_path)
				end
			end
			
		end
		
	end
end
