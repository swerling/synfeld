require 'rack/mount'

#@usher ||= Usher.new(:generator => Usher::Util::Generators::URL.new)

@app = proc do |env|

  body = "Hi there #{env[ Rack::Mount::Const::RACK_ROUTING_ARGS].inspect}"
  [
    200,          # Status code
    {             # Response headers
      'Content-Type' => 'text/plain',
      'Content-Length' => body.size.to_s,
    },
    [body]        # Response body
  ]
end

@set = nil

def add_a_route(opts = {})
  method = (opts.delete(:method) || 'GET').upcase
  string_or_regex = opts.delete(:path) || raise("You have to provide a :path")
  colon = (RUBY_VERSION =~ /^1.8/)? ':' : ''
  if string_or_regex.is_a?(String)
    regex_string = "^" + string_or_regex.gsub(/:(([^\/]+))/){|s| "(?#{colon}<#{$1}>.*)" } + "$"
    puts regex_string
    regex = %r{#{regex_string}}
  else
    regex = string_or_regex
  end
  @set.add_route(@app,
                {:path_info => regex, :request_method => method.upcase},
                opts)
end

basic_set = Rack::Mount::RouteSet.new_without_optimizations do |set|
  @set = set
#  set.add_route(@app, { :path_info => %r{^/hello/(?:<hi>.*)$}, :request_method => 'GET' }, 
#                     { :controller => 'spscontroller_a', :action => 'spsaction_a' })
#  set.add_route(@app, { :path_info => %r{^/hi/(?<ho>.*)$}, :request_method => 'GET' }, 
#                     { :controller => 'spscontroller_a', :action => 'spsaction_a' })
#  set.add_route(@app, { :path_info => '/ho/steve', :request_method => 'GET' }, 
#                     { :controller => 'spscontroller_a', :action => 'spsaction_a' })
#  set.add_route(@app, { :path_info => Rack::Mount::Utils.normalize_path('/baz') }, 
#                      { :controller => 'baz', :action => 'index' })
  add_a_route(:path => '/hillo/:name', 
              :method => 'get',
              :controller => 'spscontroller_a', 
              :action => 'spsaction_a' )
  add_a_route( :path => '/ho/:nime/blah', 
               :controller => 'spscontroller_b', 
               :action => 'spsaction_b' )
  add_a_route(:path => %r{^/hey/(?:<hi>.*)$}, :cont => 'cont_c', :act => 'action_c' )
end


run basic_set


