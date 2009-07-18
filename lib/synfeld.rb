# base ruby requires
require 'logger'

# gems dependencies
require 'rubygems'
require 'rack'
require 'rack/router'

# my files (require_all_libs_relative_to is a bones util method in synfeld_info.rb)
require 'synfeld_info'
Synfeld.require_all_libs_relative_to(__FILE__)

