require File.expand_path(File.join(File.dirname(__FILE__),'try_me.rb'))

class MyLogger < Logger
  alias :write :<<
end

use ::Rack::CommonLogger, logger = MyLogger.new('/tmp/synfeld.log')
#use Rack::Reloader, 0

try_me = TryMe.new(
  :logger => logger,
  :root_dir => File.expand_path(
    File.join(File.dirname(__FILE__), 'public')))

# Run with something like:
#   thin start -R example/try_me.ru
run try_me.as_rack_app
