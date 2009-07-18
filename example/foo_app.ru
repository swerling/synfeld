require File.join(File.dirname(__FILE__),'foo_app.rb')
run FooApp.new.as_rack_app
