
require 'time'
require 'yaml/store'
require 'uuid'

module TheFox
	module Timr
		
		class Task
			
			def initialize(path = nil)
				# Status
				#  :running
				#  :stop
				@status = :stop
				@changed = false
				
				@meta = {
					'id' => UUID.new.generate,
					'name' => nil,
					'description' => nil,
					'created' => Time.now.strftime(TIME_FORMAT),
					'modified' => Time.now.strftime(TIME_FORMAT),
				}
				@track = nil
				@timeline = []
				
				@path = path
				if !@path.nil?
					load_from_file(@path)
				end
			end
			
			def load_from_file(path)
				content = YAML::load_file(path)
				@meta = content['meta']
				@timeline = content['timeline']
					.map{ |track_raw|
						Track.from_h(self, track_raw)
					}
			end
			
			def save_to_file(basepath)
				if @changed
					path = File.expand_path("task_#{@meta['id']}.yml", basepath)
					
					timeline_c = @timeline
						.map{ |track|
							track.to_h
						}
					
					store = YAML::Store.new(path)
					store.transaction do
						store['meta'] = @meta
						store['timeline'] = timeline_c
					end
					@changed = false
				end
			end
			
			def running?
				@status == :running
			end
			
			def status
				case @status
				when :running
					'>'
				when :stop
					'|'
				end
			end
			
			def changed
				@changed = true
				@meta['modified'] = Time.now.strftime(TIME_FORMAT)
			end
			
			def id
				@meta['id']
			end
			
			def name
				@meta['name']
			end
			
			def name=(name)
				changed
				@meta['name'] = name
			end
			
			def description=(description)
				changed
				@meta['description'] = description == '' ? nil : description
			end
			
			def timeline
				@timeline
			end
			
			def start
				if !running?
					changed
					@track = Track.new(self)
					@timeline << @track
				end
				@status = :running
			end
			
			def stop
				if running? && !@track.nil?
					changed
					@track.end = Time.now
					@track = nil
				end
				@status = :stop
			end
			
			def toggle
				if running?
					stop
				else
					start
				end
			end
			
			def to_s
				name
			end
			
		end
		
	end
end
