require File.join(File.dirname(__FILE__),'../lib/synfeld.rb')

#
# Example synfeld application
#
class FooApp < Synfeld::App

  def router
    return @router ||= Rack::Router.new(nil, {}) do |r|
      r.map "/yip/",                     :get, :to => self, :with => { :action => "yip" }
      r.map "/yap/:yap_variable",        :get, :to => self, :with => { :action => "yapfoo" }
      r.map "/yap/",                     :get, :to => self, :with => { :action => "yap" }
      r.map "/:anything",                :get, :to => self, :with => { :action => "no_route" }
      r.map "/",                         :get, :to => self, :with => { :action => "home" }
    end
  end

  def yip; "yip"; end
  def yap; "yap"; end
  def home; "home"; end

  def no_route
    self.response[:body] = "route not found for: '#{self.env['REQUEST_URI']}'"
    self.response[:status_code] = 404
  end

  def yapfoo
    "yapfoo, #{self.params[:yap_variable]}"
  end
end
