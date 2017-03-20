
class Time
	
	#http://stackoverflow.com/questions/1414951/how-do-i-get-elapsed-time-in-milliseconds-in-ruby
	def to_ms
		(self.to_f * 1000.0).to_i
	end
	
end
