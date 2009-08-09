synfeld
 
by {Steven Swerling}[http://tab-a.slot-z.net]

{rdoc}[http://tab-a.slot-z.net] | {github}[http://www.github.com/swerling/synfeld]

== DESCRIPTION:

Synfeld is a web application framework that does practically nothing.

Basically this is just a tiny wrapper for the Rack::Router (see http://github.com/carllerche/rack-router). If you want a web framework that is mostly just going to serve up json blobs, and occasionally serve up some simple content (eg. for help files) and media, Synfeld makes that easy. If you need session variables, a mailer, uploading, etc, look elsewhere.

The sample app below shows pretty much everything that synfeld can do. 

Very alpha-ish stuff here. Seems to work though.

== SYNOPSIS:

Here is an example Synfeld application (foo_app.rb):

  class FooApp < Synfeld::App

    def initialize
      super(:root_dir => File.expand_path(File.join(File.dirname(__FILE__), 'public')),
            :logger => Logger.new(STDOUT))
    end

    def router
      return @router ||= Rack::Router.new(nil, {}) do |r|
        r.map "/yap/:yap_variable",        :get, :to => self, :with => { :action => "yap" }
        r.map "/my/special/route",         :get, :to => self, :with => { :action => "my_special_route" }
        r.map "/html_test",                :get, :to => self, :with => { :action => "html_test" }
        r.map "/haml_test",                :get, :to => self, :with => { :action => "haml_test" }
        r.map "/erb_test",                 :get, :to => self, :with => { :action => "erb_test" }

        # These next 2 have to come last
        r.map "/:anything_else",           :get, :to => self, :with => { :action => "handle_static" } 
        r.map "/",                         :get, :to => self, :with => { :action => "home" }
      end
    end

    # files are looked up relative to the root directory specified in initialize
    def home
      serve('haml_files/home.haml')
    end

    def my_special_route
      self.response[:status_code] = 200
      self.response[:headers]['Content-Type'] = 'text/html'
      self.response[:body] = <<-HTML
        <html>
          <body>I'm <i>special</i>.</body>
        </html>
      HTML
    end

    def yap
      "yap, #{self.params[:yap_variable]}"
    end

    def html_test 
      serve('html_files/html_test.html')
    end

    def haml_test 
      serve('haml_files/haml_test.haml', {:ran100 => Kernel.rand(100) + 1, :time => Time.now})
    end

    def erb_test 
      serve('erb_files/erb_test.erb', {:ran100 => Kernel.rand(100) + 1, :time => Time.now})
    end


  end

And here is an example rack config, foo_app.ru:

  require '/path/to/foo_app.rb'
  run FooApp.new.as_rack_app

Run FooApp w/ rackup or shotgun:

  rackup --server=thin foo.ru -p 3000

    or

  shotgun --server=thin foo.ru -p 3000

== FEATURES

When a Synfeld application handles a rack request, it 

1. Duplicates self (so it's thread safe) 
2. Sets @response, @params, @env (the rack env) 
3. Calls the action that Rack::Router route that matched. If the action returns a String, that is used for the @response[:body]

The @response is a hash used to return the rack status code, headers hash, and body.  Actions may do what they please with the response. Default response:

    @response = {
      :status_code => 200,
      :headers => {'Content-Type' => 'text/html'},
      :body => nil
    }


Actions are expected to side-effect the :status_code, :headers, and :body if the defaults are not appropriate. As a convenience, if an action returns a string, it is assumed that that string is the :body. An exception is thrown if the :body is not set to something.

As the example app above shows, you can "serve" templated content in the form of 'haml' or 'erb' files.

Requests are bound to the first matching route. The 'handle_static' action considers the request path to be a path to a file relative to the 'root_dir' specified in initialize (see example app below). 

Can currenty serve up the following types of static files:

        js, css, png, gif, jpg, jpeg, html

Can currently render the following dynamic content:

        erb, haml

Synfeld does not do partials, but you can set local variables for dynamic content.

That's it. Really not much to see here.  Just gives you a thread-safe rack-based web framework that consists of little more than a router.

== PROBLEMS

None known.

== REQUIREMENTS:

* ruby, rubygems, rack, rack-router
* For rack-router, see http://github.com/carllerche/rack-router

== INSTALL:

  First install rack and rack-router. 
  
  There's no gem for rack-router at the moment,
  to you will have to clone it and build it yourself. 
  
  Then:

    gem install swerling-synfeld --source http://gems.github.com

== LICENSE:

(The MIT License)

Copyright (c) 2009 Steven Swerling

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
