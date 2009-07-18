module Synfeld

  #
  # See the synopsis section of README.txt for usage.
  # 
  # See the RackRouter project for the kinds of routes you can setup.
  #
  # Variables of note:
  #
  #   @response
  #      a hash with keys :body, :headers, :status_code, the 3 items all rack handlers are expected to set.
  #      Body is a string, status code is an http status code integer, and headers is a hash that
  #      should conform to rack's contract.
  #
  #   @env
  #      The rack env passed into this apps #call method
  #
  #   @params
  #      The params that the matching Rack::Router route set.
  #
  class App
    attr_accessor :response, :params, :env, :logger

    # Options:
    #   :logger => where to log to.
    #              Note this is not the same thing as the rack access log (although you
    #              can pass that logger in if you want). Default: Logger.new(STDOUT)
    def initialize(opts = {})
      @logger = opts[:logger] || Logger.new(STDOUT)
    end
    
    # the router for this Synfeld::App. Subclasses are _required_ to override this.
    # (see README.txt for example usage)
    def router
      raise "#{self.class} must implement a 'router' method that returns a Rack::Router"
    end

    # Alias for #router
    def as_rack_app; self.router; end # alias_method doesn't seem to work here (it doesnt call the subclass)

    # The rack #call method
    def call(env)
      dup._call(env) # be thread-safe
    end

    #
    #  Misc Sugar
    #

    # The name of the action method, determined by the Route that Rack::Router bound to the incoming request 
    def action
      self.params[:action]
    end

    # Overridable method that handles missing action that was defined by a route
    def theres_no_action
      self.response[:body] = "Action '#{self.action}' not found in '#{self.class}'"
      self.response[:status_code] = 500
    end

    protected

      # :stopdoc:

      def _call(env)
        start_time = Time.now.to_f 

        @env = env
        @params = env['rack_router.params']
        @response = {
          :status_code => 200,
          :headers => {'Content-Type' => 'text/html'},
          :body => nil
        }

        action = self.action
        if self.respond_to?(action)
          body = self.send(self.action)
        else
          body = theres_no_action
        end

        response[:body] = body if body.is_a?(String)
        raise "You have to set the response body" if response[:body].nil?

        logger.debug("It took #{Time.now.to_f - start_time} sec for #{self.class} to handle request.")
        [response[:status_code], response[:headers], response[:body]]
      end

      # :startdoc:
  end
end



