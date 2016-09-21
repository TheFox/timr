
source 'https://rubygems.org'

group(:development) do
	if ENV['TERMKIT_LOAD_PATH']
		# Load TermKit from a local path.
		gem 'termkit', :path => ENV['TERMKIT_LOAD_PATH']
	end
	
	if ENV['SIMPLECOV_PHPUNIT_LOAD_PATH']
		# Load SimpleCov PHPUnit Formatter from a local path.
		gem 'simplecov-phpunit', :path => ENV['SIMPLECOV_PHPUNIT_LOAD_PATH']
	end
end

gemspec
