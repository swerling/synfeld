F = ::File # in .ru file, self is Rack, and Rack has it's own File class
           # So in here, Kernel::File referred to as 'F'

require F.join(F.dirname(__FILE__),'try_me.rb')

use Rack::CommonLogger, logger = Logger.new('/tmp/synfeld.log')
try_me = TryMe.new(
              :logger => logger,
              :root_dir => F.expand_path(F.join(F.dirname(__FILE__), 'public'))
             )

run try_me.as_rack_app
