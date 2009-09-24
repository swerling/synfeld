== *Synfeld*
 
by {Steven Swerling}[http://tab-a.slot-z.net]

{rdoc}[http://tab-a.slot-z.net] | {github}[http://www.github.com/swerling/synfeld]

== Description

Synfeld is a web application framework that does practically nothing.

Synfeld is little more than a small wrapper for Rack::Mount (see http://github.com/josh/rack-mount). If you want a web framework that is mostly just going to serve up json blobs, and occasionally serve up some simple content (eg. help files) and media, Synfeld makes that easy. 

The sample app below shows pretty much everything there is to know about synfeld, in particular:

* How to define routes.
* Simple rendering of erb, haml, html, json, and static files.
* In the case of erb and haml, passing variables into the template is demonstrated.
* A dymamic action where the status code, headers, and body are created 'manually.'
* The erb demo link also demos the rendering of a partial (not visible in the code below, you have to look at the template file examples/public/erb_files/erb_test.erb).

== Synopsis/Example

Here is an example Synfeld application (foo_app.rb):

  require 'synfeld'
  require 'json'

  class FooApp < Synfeld::App

    def add_routes
      add_route "/yap/:yap_variable", :action => "yap" 
      add_route "/html_test", :action => "html_test" 
      add_route "/haml_test", :action => "haml_test" 
      add_route "/erb_test",  :action => "erb_test" 
      add_route '/json_blob', :action => "json_blob" 
      add_route "/my/special/route", :action => "my_special_route", 
                                     :extra_parm1 => 'really', 
                                     :extra_parm2 => 'truly' 
      add_route '/', :action => "home" 
    end

    # files are looked up relative to the root directory specified in initialize
    def home
      render_haml('haml_files/home.haml')
    end

    def yap
      "yap, #{self.params[:yap_variable]}"
    end

    def html_test 
      render_html('html_files/html_test.html')
    end

    def haml_test 
      render_haml('haml_files/haml_test.haml', :ran100 => Kernel.rand(100) + 1, :time => Time.now)
    end

    def erb_test 
      render_erb('erb_files/erb_test.erb', :ran100 => Kernel.rand(100) + 1, :time => Time.now)
    end

    def json_blob
      hash = {:desc => 'here is the alphabet', :alphabet => ('a'..'z').collect{|ch|ch} }
      render_json hash.to_json
    end

    def my_special_route
      self.response[:status_code] = 200
      self.response[:headers]['Content-Type'] = 'text/html'
      self.response[:body] = <<-HTML
        <html>
          <body>I'm <i>special</i>, 
          #{self.params[:extra_parm1]} and #{self.params[:extra_parm2]}</body>
        </html>
      HTML
    end

  end

And here is an example rack config, foo_app.ru:

  require '/path/to/foo_app.rb'
  use Rack::CommonLogger, logger = Logger.new('/tmp/synfeld.log')
  foo_app = FooApp.new( :logger => logger, :root_dir => '/path/to/root/dir' )
  run foo_app.as_rack_app

Run FooApp w/ rackup or shotgun:

  rackup foo_app.ru -p 3000

    or

  shotgun foo_app.ru -p 3000

== Features

==== The Router

When a Synfeld application starts up, it will call your app's 'add_routes' method, where you have to create your routes using the #add_route method. Example calls to add_route:

1.  add_route %r{/some/path/(?:<somevar>.*)}, :action => "haml_test"
2.  add_route "/some/otherpath/:somevar", :action => "haml_test"
3.  add_route "/yet/anotherpath/:var", :action => "haml_test", :method => 'post', :furthermore => 'art is dead'

* At minimum, you have to provide the route and the :action to #add_route. 
* When a route is passed as a regex (the 1st add_route line above), it is passed straight through to rackmount as is, so rackmount's rules apply. 
* When using the convenience notation of the second add_route line above, the '/some/path/:somevar' is converted to a rackmount regex route under the covers, and :somevar will be passed to your app as a param (this is shown in the example code's #yap and #my_special_route methods). 
* The 3rd add_route example shows how you can set any additional parameters on the route by adding associations onto the end of the route (this is also shown in #my_special_route in the example application above). 
* If you happen to have a parameter called ':method', it will determine the request method required for the route (eg. 'get', 'put', 'post'). If the :method is not passed in, 'get' is assumed.

Note that rack-mount is an evolving project, so the examples above may have to be tweaked a bit in the future.

==== The Response

When a Synfeld application handles a rack request, it 

1. Duplicates itself (so it's thread safe) 
2. Sets @response, @params, @env (@env is just the rack env) 
3. Calls the action that the route that matched. 

The @response is a hash used to return the rack status code, headers hash, and body.  Actions may do what they please with the response. Default response:

    @response = {
      :status_code => 200,
      :headers => {'Content-Type' => 'text/html'},
      :body => nil
    }


Actions are expected to side-effect the :status_code, :headers, and :body if the defaults are not appropriate. As a convenience, if an action returns a string, it is assumed that that string is to be used as the response[:body]. An exception is thrown if the :body is not set to something. The 'Content-Length' header will be derived from the body's size.

As the example app above shows, you can serve templated content in the form of 'haml' or 'erb' files (the #erb_test and #haml_test methods in the code above).

Synfeld can currenty serve up the following types of static files:

        js, css, png, gif, jpg, jpeg, html

Synfeld can currently render the following dynamic content:

        erb, haml, json

Additional file types can be added upon request. Or you can just look at the synfeld code, which is tiny, then roll your own render method.

You can pass local variables to erb and haml. 

Rendering 'partials' is trivial and is demonstrated in the included sample application file examples/public/erb_files/erb_test.erb.

==== That's It

Synfeld just gives you a thread-safe rack-based web framework that consists of just a little more than a router.  There's really not much to see.  If you want caching, security, session access, etc, it is assumed you will add those as Rack middleware. 

== Problems

None known.

== Requirements

* ruby (either 1.8.X or 1.9.X)
* ruby, rubygems, rack, rack-router
* For rack-router, see http://github.com/carllerche/rack-router

== Install
 
  1. [install rack if necessary]
  2. gem install josh-rack-mount --source=http://gems.github.com
  3. gem install swerling-synfeld --source http://gems.github.com

    (note: I noticed sometimes josh-rack-mount will complain about rack version
    not being high enough, even if you are already on version 1.0.0. If that happens,
    you have to clone the rack-mount repo locally and just build the rack-mount gem 
    yourself)

== License

(the MIT License)

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

