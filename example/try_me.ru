#use Rack::CommonLogger, $stderr
require File.join(File.dirname(__FILE__),'try_me.rb')
run TryMe.new.as_rack_app
