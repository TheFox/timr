
module TheFox
	module Timr
		
		class HelpTableView < TheFox::TermKit::TableView
			
			def initialize
				super()
				
				table_data = ['BEGIN', 'hello', 'world', "zeile1\nzeile2", 'END']
			end
			
		end
		
	end
end
