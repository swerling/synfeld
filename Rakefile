# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'synfeld_info'

task :default => 'spec:run'

PROJ.name = 'synfeld'
PROJ.authors = 'Steven Swerling'
PROJ.email = 'sswerling@yahoo.com'
PROJ.url = 'http://tab-a.slot-z.net'
PROJ.version = Synfeld::VERSION
PROJ.rubyforge.name = 'synfeld'
PROJ.gem.dependencies = ['rack', 'rack-router']
PROJ.rdoc.opts = ["--inline-source"]
PROJ.rdoc.exclude = ["^tasks/setup\.rb$", "lib/synfeld_info.rb"]

PROJ.spec.opts << '--color'

task :default => 'spec:run'
task :myclobber => [:clobber] do
  mydir = File.join(File.dirname(__FILE__))
  sh "rm -rf #{File.join(mydir, 'pkg')}"
  sh "rm -rf #{File.join(mydir, 'doc')}"
  sh "rm -rf #{File.join(mydir, 'ext/*.log')}"
  sh "rm -rf #{File.join(mydir, 'ext/*.o')}"
  sh "rm -rf #{File.join(mydir, 'ext/*.so')}"
  sh "rm -rf #{File.join(mydir, 'ext/Makefile')}"
  sh "rm -rf #{File.join(mydir, 'ext/Makefile')}"
end
task :mypackage => [:myclobber] do
  Rake::Task['gem:package'].invoke
end
task :mydoc => [:myclobber] do
  mydir = File.join(File.dirname(__FILE__))
  sh "cp #{File.join(mydir, 'README.txt')} #{File.join(mydir, 'README.rdoc')}"
  Rake::Task['doc'].invoke
end
task :mygemspec => [:myclobber] do
  Rake::Task['gem:spec'].invoke
end
