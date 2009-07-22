require File.expand_path(File.join(File.dirname(__FILE__), '../lib/synfeld.rb'))
require 'haml'

class TryMe < Synfeld::App

  def initialize
    super(:root_dir => File.expand_path(File.join(File.dirname(__FILE__), 'public')),
          :logger => Logger.new(STDOUT))
  end

  def router
    return @router ||= Rack::Router.new(nil, {}) do |r|
#      r.map "/yap/:yap_variable",        :get, :to => self, :with => { :action => "yapfoo" }
      r.map "/my/special/route",         :get, :to => self, :with => { :action => "my_special_route" }
      r.map "/html_test",                :get, :to => self, :with => { :action => "html_test" }
      r.map "/haml_test",                :get, :to => self, :with => { :action => "haml_test" }
      r.map "/:anything_else",           :get, :to => self, :with => { :action => "no_route" } #TODO: add this automatically in Synfeld::App
      r.map "/",                         :get, :to => self, :with => { :action => "home" }
    end
  end

  def home
    render('home.haml')
  end

  def my_special_route
    self.response[:body] = "I'm special"
  end

  def html_test 
    render('html_test.html')
  end

  def haml_test 
    render('haml_test.haml')
  end

  #------------


end

