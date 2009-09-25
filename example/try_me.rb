require File.expand_path(File.join(File.dirname(__FILE__), '../lib/synfeld.rb'))
require 'json'

# This is the sample Synfeld::App described in the README.rdoc
class TryMe < Synfeld::App

  def add_routes
    add_route "/yap/:yap_variable", :action => "yap" 
    add_route "/html_test", :action => "html_test" 
    add_route "/haml_test", :action => "haml_test" 
    add_route "/erb_test",  :action => "erb_test" 
    add_route '/alphabet.:format', :action => "alphabet" 
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

  def alphabet
    alphabet = ('a'..'z').collect{|ch|ch} 
    case params[:format]
    when 'html'
      return "<html><body>#{alphabet.join("<br/>")}</body></html>"
    when 'json'
      hash = {:desc => 'here is the alphabet', :alphabet => alphabet}
      render_json hash.to_json
    else
      raise "Format not recognized: #{params[:format]}"
    end
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

