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
    attr_accessor :response, :params, :env, :root_dir, :logger

    # Options:
    #   :logger => where to log to.
    #              Note this is not the same thing as the rack access log (although you
    #              can pass that logger in if you want). Default: Logger.new(STDOUT)
    def initialize(opts = {})
      @logger = opts[:logger] || Logger.new(STDOUT)
      @root_dir = opts[:root_dir] 
      raise "You have to pass in the location of the 'root_dir', where all the files in your synfeld app are located" if self.root_dir.nil?
      #Haml::Template.options[:format] = :html5
    end
    
    # the router for this Synfeld::App. Subclasses are _required_ to override this.
    # (see README.txt for example usage)
    def router
      raise "#{self.class} must implement a 'router' method that returns a Rack::Router"
    end

    # Alias for #router
    def as_rack_app
      self.router
      # TODO: add the no_route handler here. But waiting for rack-router to settle this issue.
    end 

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

      # send an error message to the log prepended by "Synfeld: " 
      def whine msg
        logger.error("Synfeld laments: " + msg)
        return msg
      end


      # :startdoc:

      def serve(fn, local = {})
        full_fn = fn
        full_fn = File.join(self.root_dir, fn) unless File.exist?(full_fn)
        if File.exist?(full_fn)
          ext = fn.split('.').last.downcase

          self.content_type!(ext)

          case ext
          when 'html'; return serve_html(full_fn)
          when 'haml'; return serve_haml(full_fn, local)
          when 'erb';  return serve_erb(full_fn, local)
          else raise "Unrecognized file type: '#{ext}'";
          end
        else
          raise "Could not find file '#{fn}' (full path '#{full_fn}')" 
        end

      end

      def serve_html(fn)
        File.read(fn)
      end

      def serve_haml(fn, locals = {})

        if not defined? Haml
          begin
            require 'haml'
          rescue LoadError => x
            return self.whine "Haml is not installed, required in order to render '#{fn}'"
          end
        end

        Haml::Engine.new(File.read(fn) ).render(Object.new, locals)
      end

      def serve_erb(fn, locals = {})

        if not defined? Erb
          begin
            require 'erb'
          rescue LoadError => x
            return self.whine "Erb is not installed, required in order to render '#{fn}'"
          end
        end

        template = ERB.new File.read(fn)

        bind = binding
        locals.each do |n,v| 
          raise "Locals must be symbols. Not a symbol: #{n.inspect}" unless n.is_a?(Symbol) 
          eval("#{n} = locals[:#{n}]", bind)
        end
        template.result(bind)
      end

      def handle_static
        fn = File.expand_path(File.join(root_dir, self.env['REQUEST_URI']))
        #puts fn # dbg
        if File.exist?(fn) and not File.directory?(fn)
          self.content_type!(fn.split('.').last)
          File.read(fn)
        else
          return self.no_route
        end
      end

      def content_type!(ext)
        case ext.downcase
        when 'html'; t = 'text/html'
        when 'haml'; t = 'text/html'
        when 'js'; t = 'text/javascript'
        when 'css'; t = 'text/css'
        when 'png'; t = 'image/png'
        when 'gif'; t = 'image/gif'
        when 'jpg'; t = 'image/jpeg'
        when 'jpeg'; t = 'image/jpeg'
        end
        (self.response[:headers]['Content-Type'] = t) if t
      end

      def no_route
          self.response[:body] = "route not found for: '#{self.env['REQUEST_URI']}'"
          self.response[:status_code] = 404
      end

  end # class App

end # mod Synfeld



