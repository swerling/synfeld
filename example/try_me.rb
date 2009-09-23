require File.expand_path(File.join(File.dirname(__FILE__), '../lib/synfeld.rb'))

class TryMe < Synfeld::App

  def initialize
    super(:root_dir => File.expand_path(File.join(File.dirname(__FILE__), 'public')),
          :logger => Logger.new(STDOUT))
  end

  def add_routes
    add_route "/yap/:yap_variable", :action => "yap" 
    add_route "/my/special/route", :action => "my_special_route" 
    add_route "/html_test", :action => "html_test" 
    add_route "/haml_test", :action => "haml_test" 
    add_route "/erb_test", :action => "erb_test" 
    add_route '/', :action => "home" 
  end

  # files are looked up relative to the root directory specified in initialize
  def home
    render('haml_files/home.haml')
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
    render('html_files/html_test.html')
  end

  def haml_test 
    render('haml_files/haml_test.haml', :ran100 => Kernel.rand(100) + 1, :time => Time.now)
  end

  def erb_test 
    render('erb_files/erb_test.erb', :ran100 => Kernel.rand(100) + 1, :time => Time.now)
  end


end

