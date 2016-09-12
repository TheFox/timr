
module TheFox
	module Timr
		
		class Window
			
			attr_reader :current_line
			attr_reader :cursor
			
			def initialize(data = [])
				@data = data
				@content_length = 0
				@current_line = 0
				@cursor = 1
				@has_cursor = false
				@content_changed = true
				@content_refreshes = 0
				@page = []
				@page_changed = true
				@page_refreshes = 0
				
				setup
				content_refresh
			end
			
			def setup
				
			end
			
			def content_length=(content_length)
				if @content_length != content_length
					@content_changed = true
				end
				@content_length = content_length
			end
			
			def content=(data)
				@content_changed = true
				@data = data
			end
			
			def content
				@data
			end
			
			def content_changed
				@content_changed = true
			end
			
			def content_refreshes
				@content_refreshes
			end
			
			def content_refresh
				if @content_changed
					@content = content
					@content_refreshes += 1
					@content_changed = false
					
					@page_changed = true
				end
			end
			
			def page_refreshes
				@page_refreshes
			end
			
			def page
				if @page_changed
					@page = @content[@current_line, @content_length]
					@page_refreshes += 1
					@page_changed = false
				end
				
				@page
			end
			
			def page_object
				page[@cursor - 1]
			end
			
			def page_length
				cpage = page
				if cpage.nil?
					0
				else
					cpage.length
				end
			end
			
			def next_page?
				has = false
				new_current_line = @current_line + @content_length
				new_page = @content[new_current_line, @content_length]
				if !new_page.nil?
					new_page_length = new_page.length
					if new_page_length > 0
						has = true
					end
				end
				has
			end
			
			def next_page(add_lines = nil)
				if add_lines.nil?
					add_lines = @content_length
				end
				
				@page_changed = true
				@current_line += add_lines if next_page?
				cursor_set_to_last_if_out_of_range
			end
			
			def previous_page?
				@current_line > 0
			end
			
			def previous_page(length = @content_length)
				if previous_page?
					@page_changed = true
					@current_line -= length
					if @current_line < 0
						@current_line = 0
					end
				end
			end
			
			def first_page
				@page_changed = true
				@current_line = 0
				cursor_first_line
			end
			
			def last_page?
				!next_page?
			end
			
			def last_page
				if !last_page?
					@page_changed = true
					
					new_current_line = @content.length - @content_length
					if new_current_line >= 0
						@current_line = @content.length - @content_length
					end
				end
				cursor_last_line
			end
			
			def next_line
				@page_changed = true
				next_page(1)
			end
			
			def previous_line
				@page_changed = true
				previous_page(1)
			end
			
			def has_cursor?
				@has_cursor
			end
			
			def cursor_next_line
				@cursor += 1
				border = @content_length - 2
				if @cursor > border
					if last_page?
						if @cursor > @content_length
							@cursor = @content_length
						end
					else
						@cursor = border
						next_line
					end
				else
					
				end
				
				cursor_set_to_last_if_out_of_range
			end
			
			def cursor_previous_line
				@cursor -= 1
				border = 3
				if @cursor < 1
					@cursor = 1
					
					if previous_page?
						previous_line
					else
						
					end
				elsif @cursor < border
					if previous_page?
						@cursor = border
						previous_line
					end
				else
					
				end
			end
			
			def cursor_last_line
				@cursor = @content_length
				if page_length < @content_length
					@cursor = page_length
				end
			end
			
			def cursor_first_line
				@cursor = 1
			end
			
			def cursor_set_to_last_if_out_of_range
				plength = page_length
				if @cursor > plength
					@cursor = plength
				end
			end
			
			def cursor_border_top
				previous_page? ? 3 : 1
			end
			
			def cursor_border_bottom
				#next_page? ? @content_length - 2 : -1
				next_page? ? @content_length - 2 : @content_length
			end
			
			def cursor_on_inner_range?
				if previous_page?
					if next_page?
						# Middle
						@cursor > cursor_border_top && @cursor < cursor_border_bottom
					else
						# Bottom
						@cursor >= cursor_border_top
					end
				else
					if next_page?
						# First page.
						@cursor <= cursor_border_bottom
					else
						# Only one page, so middle.
						true
					end
				end
			end
			
		end
		
	end
end
