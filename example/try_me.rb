require File.expand_path(File.join(File.dirname(__FILE__), '../lib/synfeld.rb'))

class TryMe < Synfeld::App

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

