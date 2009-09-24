F = ::File 

# base ruby requires
require 'rubygems'
require 'logger'

# gems dependencies
require 'rubygems'

require 'rack'
require 'rack/mount'
require 'rack/mime'

# my files (require_all_libs_relative_to is a bones util method in synfeld_info.rb)
require F.join(File.dirname(__FILE__), 'synfeld_info')
Synfeld.require_all_libs_relative_to(__FILE__)

