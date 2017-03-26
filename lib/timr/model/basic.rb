
require 'pp' # @TODO remove pp
require 'time'
require 'yaml/store'
require 'uuid'
require 'digest/sha1'
require 'pathname'

module TheFox
	module Timr
		module Model
			
			# Basic Class
			class BasicModel
				
				attr_accessor :changed
				attr_accessor :file_path
				
				def initialize
					# id 40 chars long.
					id = Digest::SHA1.hexdigest(UUID.new.generate)
					
					@meta = {
						'id' => id,
						'short_id' => id[0, 6],
						'created' => Time.now.utc.strftime(MODEL_DATETIME_FORMAT),
						'modified' => Time.now.utc.strftime(MODEL_DATETIME_FORMAT),
					}
					@data = nil
					@changed = false
					@file_path = nil
					# pp @meta # @TODO remove pp
				end
				
				def id=(id)
					@meta['id'] = id
					@changed = true
				end
				
				def id
					@meta['id']
				end
				
				def short_id
					@meta['id'][0, 6]
				end
				
				def created=(created)
					@meta['created'] = created
				end
				
				def modified=(modified)
					@meta['modified'] = modified
				end
				
				# Mark an object as changed. Only changed objects are stored to files on save_to_file().
				def changed
					@meta['modified'] = Time.now.utc.strftime(MODEL_DATETIME_FORMAT)
					@changed = true
				end
				
				def load_from_file(path = nil)
					load = pre_load_from_file
					
					if path.nil?
						path = @file_path
						if path.nil?
							raise ModelError, 'Path cannot be nil.'
						end
					else
						@file_path = path
					end
					
					# puts "#{self.class} load_from_file: #{path} #{load}"
					if load
						content = YAML::load_file(path)
						@meta = content['meta']
						@data = content['data']
						@changed = false
					end
					
					post_load_from_file
				end
				
				def pre_load_from_file
					true
				end
				
				def post_load_from_file
				end
				
				def save_to_file(path = nil, force = false)
					store = pre_save_to_file
					
					if path.nil?
						path = @file_path
						if path.nil?
							raise ModelError, 'Path cannot be nil.'
						end
					else
						@file_path = path
					end
					
					#puts "#{self.class} save_to_file: #{store} #{@changed}"
					if force || (store && @changed)
						@meta['modified'] = Time.now.utc.strftime(MODEL_DATETIME_FORMAT)
						
						# Create underlying directories.
						unless path.dirname.exist?
							path.dirname.mkpath
						end
						
						store = YAML::Store.new(path)
						store.transaction do
							store['meta'] = @meta
							store['data'] = @data
						end
						
						@changed = false
					end
					
					post_save_to_file
				end
				
				def pre_save_to_file
					true
				end
				
				def post_save_to_file
				end
				
				def delete_file(path = nil)
					path ||= @file_path
					if path.nil?
						raise ModelError, 'Path cannot be nil.'
					end
					
					path.delete
				end
				
				# All methods in this block are static.
				class << self
					
					# Converts an SHA1 Hash into a path.
					# 
					# Function IO:
					# 
					# ```
					# 3dd50a2b50eabc84022a23ad2c06d9bb6396f978          <- input
					# 3d/d50a2b50eabc84022a23ad2c06d9bb6396f978
					# 3d/d50a2b50eabc84022a23ad2c06d9bb6396f978
					# 3d/d5/0a2b50eabc84022a23ad2c06d9bb6396f978
					# 3d/d5/0a/2b50eabc84022a23ad2c06d9bb6396f978
					# 3d/d5/0a/2b50eabc84022a23ad2c06d9bb6396f978.yml   <- output
					# ```
					def create_path_by_id(base_path, id)
						if base_path.is_a?(String)
							base_path = Pathname.new(base_path)
						end
						unless id.is_a?(String)
							raise IdError, "ID is not a String. #{id.class} given."
						end
						if id.length <= 6
							raise IdError, "ID is too short for creating a path. Minimum length: 7"
						end
						
						# puts "base_path: #{base_path}"
						# puts "id: #{id}"
						
						path_s = '%s/%s/%s/%s.yml' % [id[0, 2], id[2, 2], id[4, 2], id[6..-1]]
						# puts "path_s: #{path_s}"
						Pathname.new(path_s).expand_path(base_path)
					end
					
					# Function IO:
					# 
					# ```
					# 3d/d5/0a/2b50eabc84022a23ad2c06d9bb6396f978.yml  <- input
					# 3dd50a2b50eabc84022a23ad2c06d9bb6396f978         <- output
					# ```
					def get_id_from_path(base_path, path)
						path.relative_path_from(base_path).to_s.gsub('/', '')[0..-5]
					end
					
					def find_file_by_id(base_path, id)
						if base_path.is_a?(String)
							base_path = Pathname.new(base_path)
						end
						unless id.is_a?(String)
							raise IdError, "ID '#{id}' is not a String. #{id.class} given."
						end
						if id.length < 4
							raise IdError, "ID '#{id}' is too short for find. Minimum length: 4"
						end
						
						if id.length == 40
							path = create_path_by_id(base_path, id)
						else
							# 12/34
							search_path = '%s/%s' % [id[0, 2], id[2, 2]]
							if id.length >= 5
								# 12/34/5
								search_path << '/' << id[4]
								
								if id.length >= 6
									# 12/34/56
									search_path << id[5]
									
									if id.length >= 7
										# 12/34/56/xxxxxx
										search_path << '/' << id[6..-1]
									end
								end
							end
							search_path << '*'
							
							# puts "search_path #{search_path}"
							# puts "base_path #{base_path}"
							
							path = nil
							base_path.find.each do |file|
								# Filter all directories.
								unless file.file?
									next
								end
								
								# Filter all non-yaml files.
								unless file.basename.fnmatch('*.yml')
									next
								end
								
								rel_path = file.relative_path_from(base_path)
								unless rel_path.fnmatch(search_path)
									next
								end
								
								if path
									raise ModelError.new(id), "ID '#{id}' is not a unique identifier."
								else
									path = file
									
									# Do not break the loop here.
									# Iterate all keys to make sure the ID is unique.
								end
							end
						end
						
						if path && path.exist?
							return path
						end
						raise ModelError, "Could not find a file for ID '#{id}' at #{base_path}."
					end
					
				end
				
			end # class Model
			
		end # module Model
	end # module Timr
end #module TheFox
