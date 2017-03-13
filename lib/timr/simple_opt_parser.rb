
# Simple Option Parser
# Because OptParse sucks. Parsing arguments should be easy. :(

# Covered Usecases
#   -a
#   --all
#   -a --all
#   -a -b val
#   -a -b val cmd
#   -a -b val cmd1 cmd2
#   -a -b val1 val2
#   -a -b val1 val2 cmd1 cmd2
#   -ab
#   -ab val

# Usage
# optparser = SimpleOptParser.new
# optparser.register_option(['-a'])
# optparser.register_option(['-b'])
# optparser.register_option(['-c'], 1)
# opts = optparser.parse('-a -b -c val')

module TheFox
	module Timr
		
		class SimpleOptParser
			
			attr_reader :options
			attr_reader :unknown_options
			
			def initialize
				#  -a   => 0
				# --all => 0
				#  -b   => 1
				@valid_options = Hash.new
				
				# a   => 0
				# all => 0
				# b   => 1
				# @valid_options_without_prefix = Hash.new
				
				# Parsed Options (+Commands)
				@options = Array.new
				
				# Not Recognized Options
				@unknown_options = Array.new
			end
			
			# number_values
			#   0 = no value, just a switch
			#  -1 = unlimited
			#   n = n values
			def register_option(aliases, number_values = 0)
				aliases.each do |ali|
					@valid_options[ali] = number_values
					
					# if ali[0] == '-'
					# 	if ali[1] == '-'
					# 		# --arg
					# 		# Cut the two first characters.
					# 		@valid_options_without_prefix[ali[2..-1]] = number_values
					# 	else
					# 		# -a
					# 		# Cut only the first character.
					# 		@valid_options_without_prefix[ali[1..-1]] = number_values
					# 	end
					# end
				end
			end
			
			def parse(args)
				# Reset previous options.
				@options = []
				
				# puts "parse '#{args}'"
				
				if args.is_a?(Array)
					pre_argv = args
				else
					pre_argv = args.split(' ')
				end
				puts "pre_argv '#{pre_argv}'"
				
				argv = []
				
				# Pre-process Special Argument (Compact)
				# For example '-abcd' is '-a -b -c -d'.
				pre_argv.each do |arg|
					if arg[0] == '-'
						if arg[1] == '-'
							# Normal --arg
							argv << arg
						else
							if arg.length > 2
								# Special -ab
								arg = arg[1..-1]
								
								# Add each single argument separate.
								# Array ['-abc'] will become ['-a', '-b', '-c'].
								arg.length.times do |n|
									argv << "-#{arg[n]}"
								end
							else
								# Normal -a
								argv << arg
							end
						end
					else
						# Commands, Values, etc
						argv << arg
					end
				end
				
				puts "argv '#{argv}'"
				
				loop_c = 0 # Limit the loop.
				while argv.length > 0 && loop_c < 1024
					loop_c += 1
					
					arg = argv.shift
					# puts "arg '#{arg}' '#{argv}'"
					
					if arg[0] == '-'
						# puts "has - at begin"
						if @valid_options[arg]
							# Recognized Argument
							
							number_values = @valid_options[arg]
							
							if number_values == 0
								# No values. Like Command.
								@options << [arg]
							elsif number_values == -1
								# Eat all the arguments. Nom nom nom.
								arg_values = []
								sub_loop_c = 0 # Limit the loop.
								while argv.length > 0 && sub_loop_c < 1024
									sub_loop_c += 1
									
									arg = argv.shift
									
									# When reaching the end.
									unless arg
										break
									end
									
									arg_values << arg
								end
								@options << arg_values
							else
								# n values.
								# puts "n values rest=#{argv.length} '#{argv}'"
								
								arg_values = []
								sub_loop_c = 0 # Limit the loop.
								while argv.length > 0 && sub_loop_c < number_values && sub_loop_c < 1024
									sub_loop_c += 1
									
									val = argv.shift
									# puts "arg val: '#{val}'   rest=#{argv.length} '#{argv}'"
									
									# When reaching the end.
									unless val
										raise ArgumentError, "SimpleOptParser: Argument '#{arg}' expects #{number_values} value(s). Found #{sub_loop_c}."
									end
									
									if @valid_options[val]
										raise ArgumentError, "SimpleOptParser: Argument '#{arg}' expects #{number_values} value(s). Found another Argument '#{val}'."
									end
									
									arg_values << val
								end
								
								if arg_values.length != number_values
									raise ArgumentError, "SimpleOptParser: Argument '#{arg}' expects #{number_values} value(s), #{arg_values.length} given."
								end
								
								arg_values.unshift(arg)
								@options << arg_values
							end
						else
							# Unknown Arguments
							# '-ab' arguments will be processed in pre_argv.
							@unknown_options << arg
							puts "unknown '#{arg}'"
						end
					else
						# Command
						# puts 'is a command'
						@options << [arg]
					end
					
					# puts
				end
				
				@options
			end
			
			# Do not re-parse. Verify an already parsed array.
			def verify(opts)
				puts "verify '#{opts}'"
				opts.each do |opt_ar|
					arg = opt_ar.first
					
					number_values = @valid_options[arg]
					if number_values.nil?
						# Unknown Arguments
					else
						# Argument is valid.
						
						# Check length.
						if number_values == 0
							if opt_ar.length > 0
								raise ArgumentError, "SimpleOptParser: Argument '#{arg}' expects no values, #{opt_ar.length} given."
							end
						elsif number_values == -1
							# Always OK. Keep eating, Pacman.
						else
							if number_values != opt_ar.length
								raise ArgumentError, "SimpleOptParser: Argument '#{arg}' expects #{number_values} value(s), #{opt_ar.length} given."
							end
						end
					end
				end
				
				true
			end
			
		end # class SimpleOptParser
	
	end # module Timr
end # module TheFox

