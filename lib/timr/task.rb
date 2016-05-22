
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
					'created' => Time.now.utc.strftime(TIME_FORMAT_FILE),
					'modified' => Time.now.utc.strftime(TIME_FORMAT_FILE),
				}
				@track = nil
				@timeline = []
				@timeline_diff_total = nil
				
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
				path = File.expand_path("task_#{@meta['id']}.yml", basepath)
				
				if @changed || !@track.nil?
					timeline_c = @timeline
						.map{ |track|
							h = track.to_h
							h['e'] = Time.now.utc.strftime(TIME_FORMAT_FILE) if !h.has_key?('e') || h['e'].nil?
							h
						}
					
					store = YAML::Store.new(path)
					store.transaction do
						store['meta'] = @meta
						store['timeline'] = timeline_c
					end
					@changed = false
				end
				
				path
			end
			
			def running?
				@status == :running
			end
			
			def paused?
				@status == :paused
			end
			
			def status
				case @status
				when :running
					?>
				when :paused
					?|
				when :stop
					?.
				end
			end
			
			def changed
				@changed = true
				@meta['modified'] = Time.now.utc.strftime(TIME_FORMAT_FILE)
			end
			
			def id
				@meta['id']
			end
			
			def name
				@meta['name'].to_s
			end
			
			def name=(name)
				@changed = true
				@meta['name'] = name
			end
			
			def description
				@meta['description']
			end
			
			def description=(description)
				@changed = true
				@meta['description'] = description == '' ? nil : description
			end
			
			def track
				@track
			end
			
			def has_track?
				!@track.nil?
			end
			
			def timeline
				@timeline
			end
			
			def start(parent_track = nil)
				create_new_track = false
				
				if running?
					if !parent_track.nil?
						if @track.description != parent_track.description
							stop
							create_new_track = true
						end
					end
				elsif paused?
					parent_track = @track
					create_new_track = true
				else
					create_new_track = true
				end
				
				if create_new_track
					@track = Track.new
					if !parent_track.nil?
						@track.parent = parent_track
						@track.description = parent_track.description
					end
					
					@track.task = self
					@track.begin_time = Time.now
					@timeline << @track
					
					@changed = true
				end
				
				@status = :running
				
				create_new_track
			end
			
			def pause
				if running? && !@track.nil?
					@status = :paused
					@changed = true
					@track.end_time = Time.now
					@timeline_diff_total = nil
				end
			end
			
			def stop
				if !@track.nil?
					if running?
						@changed = true
						@track.end_time = Time.now
					end
					
					@track = nil
					@timeline_diff_total = nil
				end
				
				@status = :stop
			end
			
			def toggle
				if running?
					pause
				else
					start
				end
			end
			
			def to_s
				track_description = ''
				if has_track? && !@track.description.nil? && @track.description.to_s.length > 0
					track_description = ": #{@track.description}"
				end
				'%s%s' % [name, track_description]
			end
			
			def to_list_s
				name
			end
			
			def run_time_track(end_time = Time.now)
				hours = 0
				minutes = 0
				seconds = 0
				
				if running? && has_track?
					diff = (end_time - @track.begin_time).to_i.abs
					hours = diff / 3600
					
					diff -= hours * 3600
					minutes = diff / 60
					
					diff -= minutes * 60
					seconds = diff
				end
				
				[hours, minutes, seconds]
			end
			
			def run_time_total(end_time = Time.now)
				# Cache all other tracks.
				if @timeline_diff_total.nil?
					@timeline_diff_total = @timeline
						.select{ |track|
							if running?
								track != @track
							else
								true
							end
						}
						.map{ |track| track.diff }
						.inject(:+)
				end
				
				hours = 0
				minutes = 0
				seconds = 0
				
				track_diff = 0
				if running?
					track_diff = @track.diff(end_time)
				end
				
				diff = @timeline_diff_total.to_i + track_diff
				hours = diff / 3600
				
				diff -= hours * 3600
				minutes = diff / 60
				
				diff -= minutes * 60
				seconds = diff
				
				[hours, minutes, seconds]
			end
			
		end
		
	end
end
