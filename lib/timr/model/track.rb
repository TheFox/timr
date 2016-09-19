
require 'time'
require 'uuid'
require 'thefox-ext'
require 'termkit'

module TheFox
	module Timr
		
		class Track < TheFox::TermKit::Model
			
			attr_accessor :id
			attr_accessor :parent
			attr_accessor :parent_id
			attr_accessor :task
			attr_reader :description
			
			def initialize
				super()
				
				#puts 'Track initialize'
				
				@id = UUID.new.generate
				@parent = nil
				@parent_id = nil
				@task = nil
				@begin_time = nil
				@end_time = nil
				@description = nil
			end
			
			def begin_time=(begin_time)
				@begin_time = nil
				@begin_time = begin_time.utc if !begin_time.nil?
			end
			
			def begin_time
				if !@begin_time.nil?
					@begin_time.localtime
				else
					nil
				end
			end
			
			def end_time=(end_time)
				@end_time = nil
				@end_time = end_time.utc if !end_time.nil?
			end
			
			def end_time
				if !@end_time.nil?
					@end_time.localtime
				else
					nil
				end
			end
			
			def description=(description)
				@description = description == '' ? nil : description
			end
			
			def diff(end_time = nil)
				end_time = @end_time if !@end_time.nil?
				
				if !@begin_time.nil? && !end_time.nil?
					(end_time - @begin_time).abs.to_i
				else
					0
				end
			end
			
			def name
				name_s = ''
				if !@task.nil?
					name_s += @task.to_s
				end
				if !@description.nil? && @description.length > 0
					if name_s.length > 0
						name_s += ': '
					end
					name_s += @description
				end
				name_s
			end
			
			def to_h
				h = {
					'id' => @id,
					#'p' => nil, # parent_id
					#'b' => nil, # begin time
					#'e' => nil, # end time
					#'d' => nil, # description
				}
				h['p'] = @parent.id if !@parent.nil?
				h['p'] = @parent_id if !@parent_id.nil?
				
				h['b'] = @begin_time.utc.strftime(TIME_FORMAT_FILE) if !@begin_time.nil?
				h['e'] = @end_time.utc.strftime(TIME_FORMAT_FILE) if !@end_time.nil?
				
				#h['d'] = @description if !@description.nil?
				d = description
				h['d'] = d if !d.nil?
				
				h
			end
			
			def to_s
				end_date = nil
				end_time_s = 'xx:xx'
				if !@end_time.nil?
					end_date = @end_time.localtime.to_date
					end_time_s = @end_time.localtime.strftime('%R')
				end
				
				begin_date_s = ''
				begin_date = @begin_time.localtime.to_date
				end_date_s = ''
				if (begin_date != end_date && !end_date.nil?) || !begin_date.today?
					begin_date_s = @begin_time.localtime.strftime('%F')
					end_date_s = @end_time.localtime.strftime('%F') if !@end_time.nil?
				end
				
				'%10s %5s - %5s %10s    %s' % [
					begin_date_s, @begin_time.localtime.strftime('%R'), end_time_s, end_date_s, name]
			end
			
			def self.from_h(task = nil, h)
				t = Track.new
				t.task = task
				t.id = h['id'] if h.has_key?('id')
				t.parent_id = h['p'] if h.has_key?('p')
				t.begin_time = Time.parse(h['b']) if h.has_key?('b')
				t.end_time   = Time.parse(h['e']) if h.has_key?('e')
				t.description = h['d'] if h.has_key?('d')
				
				t
			end
			
		end
		
	end
end
