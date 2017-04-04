
class Time
	
	# See [How do I get elapsed time in milliseconds in Ruby?](http://stackoverflow.com/questions/1414951/how-do-i-get-elapsed-time-in-milliseconds-in-ruby)
	# 
	# Not really used. Only to measure the execution from start to end. See `bin/timr`.
	def to_ms
		(self.to_f * 1000.0).to_i
	end
	
end
