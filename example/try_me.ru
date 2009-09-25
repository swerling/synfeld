require ::File.join(::File.dirname(__FILE__),'try_me.rb')
use Rack::CommonLogger, logger = Logger.new('/tmp/synfeld.log')
try_me = TryMe.new( :logger => logger,
                    :root_dir => ::File.expand_path(::File.join(::File.dirname(__FILE__), 'public')))
run try_me.as_rack_app
