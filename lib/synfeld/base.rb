module Synfeld # :nodoc:

  #
  # See the synopsis section of README.rdoc for usage.
  # 
  # See the README.rdoc for an overview of an Synfeld::App, and see the Rack::Mount project for 
  # more information on Rack::Mount style routing. 
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
  #      The params as determined by the matching Rack::Mount route.
  #
  #   @root_dir
  #      This dir is prepended to relative paths to locate files.
  #
  #   @logger
  #      Either you pass in the @logger that synfeld uses, or it sets one up on STDOUT.
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
    end
    
    #
    #            RACK PLUMBING
    #

    # Return self as a rackup-able rack application.
    def as_rack_app
      routes = Rack::Mount::RouteSet.new_without_optimizations do |set|
        @set = set
        self.add_routes
        add_route %r{^.*$},  :action => "render_static" 
      end
      app = Rack::Builder.new {
        #use Rack::CommonLogger, $stderr
        #use Rack::Reloader, 0
        run routes
      }.to_app
    end 

    # The rack #call method
    def call(env)
      dup._call(env) # be thread-safe
    end

    #
    #            ROUTING
    #

    # This is a crucial part of synfeld. See the README for a full explanation of how to 
    # use this method.
    def add_route(string_or_regex, opts = {})
      raise "You have to provide an :action method to call" unless opts[:action]
      method = (opts.delete(:method) || 'GET').to_s.upcase

      # Adapt string_or_regex into a rack-mount regex route. If it is a string, convert it to a
      # rack-mount compatable regex. In paths that look like /some/:var/in/path, convert the ':var'
      # bits to rack-mount variables.
      if string_or_regex.is_a?(String)
        regex_string = "^" + string_or_regex.gsub(/:(([^\/]+))/){|s| "(?:<#{$1}>.*)" } + "$"
        regex = %r{#{regex_string}}
        #puts regex_string # dbg
      else
        regex = string_or_regex
      end

      # Add the route to rack-mount
      @set.add_route(self,
                    {:path_info => regex, :request_method => method.upcase},
                    opts)
    end

    #
    #            ACCESSORS & SUGAR
    #

    # The name of the action method bound to the route that mathed the incoming request.
    def action
      self.params[:action]
    end

    protected

      def _call(env) # :nodoc:
        begin
          start_time = Time.now.to_f 
          @env = env
          @params = env[ Rack::Mount::Const::RACK_ROUTING_ARGS ]
          @response = {
            :status_code => 200,
            :headers => {'Content-Type' => 'text/html'},
            :body => nil
          }

          action = self.action
          if self.respond_to?(action)
            result = self.send(self.action)
          else
            result = self.no_action
          end
          
          if result.is_a?(String)
            response[:body] = result
          else
            raise "You have to set the response body" if response[:body].nil?
          end

          response[:headers]["Content-Length"] = response[:body].size.to_s

          logger.debug("It took #{Time.now.to_f - start_time} sec for #{self.class} to handle request.")
          [response[:status_code], response[:headers], Array(response[:body])]
        rescue Exception => e
          # It seems like we should get this next line for free from the CommonLogger, so I guess
          # I'm doing something wrong, missing some piece of rack middleware or something. Until I
          # figure it out, I'm explicitly logging the exception manually.
          self.whine "#{e.class}, #{e}\n\t#{e.backtrace.join("\n\t")} "
          raise e
        end
      end
      # :startdoc:


      #
      #            EXCEPTIONS
      #

      # send an error message to the log prepended by "Synfeld: " 
      def whine msg
        logger.error("Synfeld laments: " + msg)
        return msg
      end


      # Overrideable method that handles a missing action that was defined by a route
      def no_action
        self.response[:body] = "Action '#{self.action}' not found in '#{self.class}'"
        self.response[:status_code] = 500
      end

      # Overrideable method that handles 404
      def no_route
          self.response[:body] = "route not found for: '#{self.env['REQUEST_URI']}'"
          self.response[:status_code] = 404
      end

      #
      #            RENDERING
      #

      # Render an html file. 'fn' is a full path, or a path relative to @root_dir.
      def render_html(fn)
        F.read(full_path(fn))
      end

      # Serve up a blob of json (just sets Content-Type to 'text/javascript' and 
      # sets the body to the json passed in to this method).
      def render_json(json)
        self.response[:headers]['Content-Type'] = 'text/javascript'
        self.response[:body] = json
      end

      # Render a haml file. 'fn' is a full path, or a path relative to @root_dir.
      # 'locals' is a hash definining variables to be passed to the template.
      def render_haml(fn, locals = {})

        if not defined? Haml
          begin
            require 'haml'
          rescue LoadError => x
            return self.whine("Haml is not installed, required in order to render '#{fn}'")
          end
        end

        Haml::Engine.new(F.read(full_path(fn)) ).render(Object.new, locals)
      end

      # Render an erb file. 'fn' is a full path, or a path relative to @root_dir.
      # 'locals' is a hash definining variables to be passed to the template.
      def render_erb(fn, locals = {})

        if not defined? Erb
          begin
            require 'erb'
          rescue LoadError => x
            return self.whine("Erb is not installed, required in order to render '#{fn}'")
          end
        end

        template = ERB.new F.read(full_path(fn))

        bind = binding
        locals.each do |n,v| 
          raise "Locals must be symbols. Not a symbol: #{n.inspect}" unless n.is_a?(Symbol) 
          eval("#{n} = locals[:#{n}]", bind)
        end
        template.result(bind)
      end

      def render_static
        fn = F.expand_path(F.join(root_dir, self.env['REQUEST_URI']))
        #puts fn # dbg
        if F.exist?(fn) and not F.directory?(fn)
          self.content_type!(fn.split('.').last)
          F.read(fn)
        else
          return self.no_route
        end
      end

      #
      #            UTIL
      #

      # Given a file extention, determine the 'Content-Type' and then set the
      # @response[:headers]['Content-Type']. Unrecognized extentions are
      # set to content type of 'text/plain'.
      def content_type!(ext)
        case ext.downcase
        when 'haml'; t = 'text/html'
        when 'erb'; t = 'text/html'
# I believe all the rest are determined accurately by the Rack::Mime.mime_type call in the else clause below.
#        when 'html'; t = 'text/html'
#        when 'js'; t = 'text/javascript'
#        when 'css'; t = 'text/css'
#        when 'png'; t = 'image/png'
#        when 'gif'; t = 'image/gif'
#        when 'jpg'; t = 'image/jpeg'
#        when 'jpeg'; t = 'image/jpeg'
        else t = Rack::Mime.mime_type('.' + ext, 'text/plain')
        end
        #puts("----#{ext}:" + t.inspect) # dbg
        (self.response[:headers]['Content-Type'] = t) if t
      end

      # Return fn if a file by that name exists. If not, concatenate the @root_dir with the fn, and
      # return that if it exists. Raise if the actual file cannot be determined. 
      #
      # NOTE: no effort is made to protect access to files outside of your application's root
      # dir. If you permit filepaths as request parameters, then it is up to you to make sure
      # that they do not point to some sensitive part of your file-system. 
      def full_path(fn)
        if F.exist?(fn)
          return fn
        elsif F.exist?(full_fn = F.join(self.root_dir, fn))
          return full_fn
        else
          raise "Could not find file '#{fn}' (full path '#{full_fn}')" 
        end
      end

  end # class App

end # mod Synfeld



